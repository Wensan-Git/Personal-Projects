package pbservice

import (
	"fmt"
	"log"
	"math/rand"
	"net"
	"net/rpc"
	"os"
	"strconv"
	"sync"
	"syscall"
	"time"
	"viewservice"
)

//import "strconv"

// Debugging
const Debug = 0

func DPrintf(format string, a ...interface{}) (n int, err error) {
  if Debug > 0 {
    n, err = fmt.Printf(format, a...)
  }
  return
}

type PBServer struct {
  l net.Listener
  mu sync.Mutex
  dead bool // for testing
  unreliable bool // for testing
  me string
  vs *viewservice.Clerk
  done sync.WaitGroup
  finish chan interface{}
  data map[string]string
  currView viewservice.View
  cachedRequest map[int64]string
  synched bool
  // Your declarations here.
}

func (pb *PBServer) ForwardGet(args *GetArgs, reply *GetReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  _, thisOk := pb.cachedRequest[args.RequestId]
  if thisOk {
    reply.Value = pb.cachedRequest[args.RequestId]
    reply.Err = OK
  }
  if pb.me != pb.currView.Backup {
    reply.Err = ErrWrongServer
  } else {
    reply.Value = pb.data[args.Key]
    reply.Err = OK
  }
  return nil
}

func (pb *PBServer) ForwardPut(args *PutArgs, reply *PutReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  _, thisOk := pb.cachedRequest[args.RequestId]
  if thisOk {
    reply.PreviousValue = pb.cachedRequest[args.RequestId]
    reply.Err = OK
    return nil
  }
  if pb.me != pb.currView.Backup {
    reply.Err = ErrWrongServer
  } else {
    if args.DoHash {
      prev := pb.data[args.Key]
      reply.PreviousValue = prev
      strValue := strconv.Itoa(int(hash(pb.data[args.Key] + args.Value)))
      pb.data[args.Key] = strValue
      pb.cachedRequest[args.RequestId] = prev
      reply.Err = OK
    } else {
      prev := pb.data[args.Key]
      reply.PreviousValue = prev
      pb.data[args.Key] = args.Value
      pb.cachedRequest[args.RequestId] = prev
      reply.Err = OK
    }
  }
  return nil
}


func (pb *PBServer) Sync(args *SyncArgs, reply *SyncReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  view, _ := pb.vs.Ping(pb.currView.Viewnum)
  if view.Primary == pb.me {
    reply.Data = pb.data
    reply.Cache = pb.cachedRequest
    reply.Err = OK
  } else {
    reply.Err = ErrWrongServer
  }
  return nil
}

func (pb *PBServer) Send(args *SendArgs, reply *SendReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  view, _ := pb.vs.Ping(pb.currView.Viewnum)
  if view.Backup == pb.me {
    pb.data = args.Data
    pb.cachedRequest = args.Cache
    pb.synched = true
    reply.Err = OK
  } else {
    reply.Err = ErrWrongServer
  }
  return nil
}


func (pb *PBServer) CheckSynched(args *CheckSyncArgs, reply *CheckSyncReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  reply.Synched = pb.synched
  return nil
}

func (pb *PBServer) UpdateSynched(args *UpdateSyncArgs, reply *UpdateSyncReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  view, _ := pb.vs.Ping(pb.currView.Viewnum)
  if view.Backup == pb.me {
    pb.synched = true
    reply.Err = OK
  } else {
    reply.Err = ErrWrongServer
  }
  return nil
}


func (pb *PBServer) Put(args *PutArgs, reply *PutReply) error {
  pb.mu.Lock()
  defer pb.mu.Unlock()
  _, thisOk := pb.cachedRequest[args.RequestId]
  if thisOk {
    reply.PreviousValue = pb.cachedRequest[args.RequestId]
    reply.Err = OK
    return nil
  }
  if pb.me == pb.currView.Primary {
    if pb.currView.Backup != "" {
      // 在这里尝试synch backup
      checkArgs := CheckSyncArgs{}
      var checkReply CheckSyncReply
      synchOk := call(pb.currView.Backup, "PBServer.CheckSynched", &checkArgs, &checkReply)
      if synchOk && checkReply.Synched {
        // this block should only execute once backup is synched
        thisArgs := PutArgs{Key: args.Key, Value: args.Value, DoHash: args.DoHash}
        var thisReply PutReply
        ok := call(pb.currView.Backup, "PBServer.ForwardPut", &thisArgs, &thisReply)
        // case: when backup 
        if ok && thisReply.Err != ErrWrongServer {
          if thisReply.PreviousValue == pb.data[args.Key] {
            if args.DoHash {
              prev := pb.data[args.Key]
              reply.PreviousValue = prev
              strValue := strconv.Itoa(int(hash(pb.data[args.Key] + args.Value)))
              pb.data[args.Key] = strValue
              pb.cachedRequest[args.RequestId] = prev
              reply.Err = OK
            } else {
              prev := pb.data[args.Key]
              reply.PreviousValue = prev
              pb.data[args.Key] = args.Value
              pb.cachedRequest[args.RequestId] = prev
              reply.Err = OK
            }
          } else {
            reply.Err = ErrWrongServer
          }
        } else {
          reply.Err = ErrWrongServer
        }

      } else {
        // if unsynched, then sync first:
        // loop until backup is synched
        for {
          sendArgs := SendArgs{Data: pb.data, Cache: pb.cachedRequest}
          var sendReply SendReply
          sendOk := call(pb.currView.Backup, "PBServer.Send", &sendArgs, &sendReply)
          if sendOk && sendReply.Err == OK {
            // updateArgs := UpdateSyncArgs{}
            // var updateReply UpdateSyncReply
            // updateOk := call(pb.currView.Backup, "PBServer.UpdateSynched", &updateArgs, &updateReply)
            // if updateOk && updateReply.Err != ErrWrongServer {
            //   break
            // }
            break
            
          }
        }
        thisArgs := PutArgs{Key: args.Key, Value: args.Value, DoHash: args.DoHash}
        var thisReply PutReply
        ok := call(pb.currView.Backup, "PBServer.ForwardPut", &thisArgs, &thisReply)
        // case: when backup 
        if ok && thisReply.Err != ErrWrongServer {
          if thisReply.PreviousValue == pb.data[args.Key] {
            if args.DoHash {
              prev := pb.data[args.Key]
              reply.PreviousValue = prev
              strValue := strconv.Itoa(int(hash(pb.data[args.Key] + args.Value)))
              pb.data[args.Key] = strValue
              pb.cachedRequest[args.RequestId] = prev
              reply.Err = OK
            } else {
              prev := pb.data[args.Key]
              reply.PreviousValue = prev
              pb.data[args.Key] = args.Value
              pb.cachedRequest[args.RequestId] = prev
              reply.Err = OK
            }
          } else {
            reply.Err = ErrWrongServer
          }
        } else {
          reply.Err = ErrWrongServer
        }
      }

    } else {
      if args.DoHash {
        prev := pb.data[args.Key]
        reply.PreviousValue = prev
        strValue := strconv.Itoa(int(hash(pb.data[args.Key] + args.Value)))
        pb.data[args.Key] = strValue
        pb.cachedRequest[args.RequestId] = prev
        reply.Err = OK
      } else {
        prev := pb.data[args.Key]
        reply.PreviousValue = prev
        pb.data[args.Key] = args.Value
        pb.cachedRequest[args.RequestId] = prev
        reply.Err = OK
      }
    }
  } else {
    reply.Err = ErrWrongServer
  }
  
  return nil
}

func (pb *PBServer) Get(args *GetArgs, reply *GetReply) error {
  // 检查自己是不是primary 并且 nonforwarded
  pb.mu.Lock()
  defer pb.mu.Unlock()
  _, thisOk := pb.cachedRequest[args.RequestId]
  if thisOk {
    reply.Value = pb.cachedRequest[args.RequestId]
    reply.Err = OK
    return nil
  }
  if pb.me == pb.currView.Primary {
    if pb.currView.Backup != "" {
      // 在这里尝试synch backup
      checkArgs := CheckSyncArgs{}
      var checkReply CheckSyncReply
      synchOk := call(pb.currView.Backup, "PBServer.CheckSynched", &checkArgs, &checkReply)
      if synchOk && checkReply.Synched {
        thisArgs := GetArgs{Key: args.Key}
        var thisReply GetReply
        ok := call(pb.currView.Backup, "PBServer.ForwardGet", &thisArgs, &thisReply)
        if ok && thisReply.Err != ErrWrongServer {
          fmt.Printf("error values %v, %v", thisReply.Value, pb.data[args.Key])
          if thisReply.Value == pb.data[args.Key] {
            prev := pb.data[args.Key]
            reply.Value = prev
            pb.cachedRequest[args.RequestId] = prev
            reply.Err = OK
          } else {
            fmt.Printf("error is 1 %v", ok)
            reply.Err = ErrWrongServer
          }
        } else {
          fmt.Printf("error is 2")
          reply.Err = ErrWrongServer
        }

      } else {
        // loop until backup is synched
        for {
          sendArgs := SendArgs{Data: pb.data, Cache: pb.cachedRequest}
          var sendReply SendReply
          sendOk := call(pb.currView.Backup, "PBServer.Send", &sendArgs, &sendReply)
          if sendOk && sendReply.Err == OK {
            // updateArgs := UpdateSyncArgs{}
            // var updateReply UpdateSyncReply
            // updateOk := call(pb.currView.Backup, "PBServer.UpdateSynched", &updateArgs, &updateReply)
            // if updateOk && updateReply.Err != ErrWrongServer {
            //   break
            // }
            break
          }
        }
        // once synched, get value from backup and compare with primary's result
        thisArgs := GetArgs{Key: args.Key}
        var thisReply GetReply
        ok := call(pb.currView.Backup, "PBServer.ForwardGet", &thisArgs, &thisReply)
        if ok && thisReply.Err != ErrWrongServer {
          fmt.Printf("error values %v, %v", thisReply.Value, pb.data[args.Key])
          if thisReply.Value == pb.data[args.Key] {
            prev := pb.data[args.Key]
            reply.Value = prev
            pb.cachedRequest[args.RequestId] = prev
            reply.Err = OK
          } else {
            fmt.Printf("error is 1 %v", ok)
            reply.Err = ErrWrongServer
          }
        } else {
          fmt.Printf("error is 2")
          reply.Err = ErrWrongServer
        }
        
      }
    } else {
      prev := pb.data[args.Key]
      reply.Value = prev
      pb.cachedRequest[args.RequestId] = prev
      reply.Err = OK
    }
  } else {
    fmt.Printf("error is 3")
    reply.Err = ErrWrongServer
  }
  // 如果是上面情况，forward给backup一个request，等待返回，对比返回，如果一样，返回，不一样就wrong server error
  // 如果不是primary，看看是不是backup并且是 forwarded
  // 如果是上面情况，返回存储值
  // Your code here.
  return nil
}


// ping the viewserver periodically.
func (pb *PBServer) tick() {
  // pb.mu.Lock()
  // defer pb.mu.Unlock()
  // // fmt.Printf("hihi")
  // view, _ := pb.vs.Ping(pb.currView.Viewnum)
  // if pb.me == view.Backup && pb.currView.Viewnum == 0 {
  //   // Call the synching function
  //   args := SyncArgs{}
  //   var reply SyncReply
  //   ok := call(view.Primary, "PBServer.Sync", &args, &reply)
  //   if ok && reply.Err != ErrWrongServer {
  //     // update database
  //     pb.data = reply.Data
  //     pb.cachedRequest = reply.Cache
  //   }
  // }
  // pb.currView = view
  pb.mu.Lock()
  defer pb.mu.Unlock()
  fmt.Printf("%v, ticked!!!!!! \n", pb.me)

  view, _ := pb.vs.Ping(pb.currView.Viewnum)
  pb.currView = view
}


// tell the server to shut itself down.
// please do not change this function.
func (pb *PBServer) kill() {
  pb.dead = true
  pb.l.Close()
}


func StartServer(vshost string, me string) *PBServer {
  pb := new(PBServer)
  pb.me = me
  pb.vs = viewservice.MakeClerk(me, vshost)
  pb.finish = make(chan interface{})
  // Your pb.* initializations here.
  pb.data = make(map[string]string)
  pb.currView = viewservice.View{Viewnum: 0, Primary: "", Backup: ""}
  pb.cachedRequest = make(map[int64]string)
  pb.synched = false

  rpcs := rpc.NewServer()
  rpcs.Register(pb)

  os.Remove(pb.me)
  l, e := net.Listen("unix", pb.me);
  if e != nil {
    log.Fatal("listen error: ", e);
  }
  pb.l = l

  // please do not change any of the following code,
  // or do anything to subvert it.

  go func() {
    for pb.dead == false {
      conn, err := pb.l.Accept()
      if err == nil && pb.dead == false {
        if pb.unreliable && (rand.Int63() % 1000) < 100 {
          // discard the request.
          conn.Close()
        } else if pb.unreliable && (rand.Int63() % 1000) < 200 {
          // process the request but force discard of reply.
          c1 := conn.(*net.UnixConn)
          f, _ := c1.File()
          err := syscall.Shutdown(int(f.Fd()), syscall.SHUT_WR)
          if err != nil {
            fmt.Printf("shutdown: %v\n", err)
          }
          pb.done.Add(1)
          go func() {
            rpcs.ServeConn(conn)
            pb.done.Done()
          }()
        } else {
          pb.done.Add(1)
          go func() {
            rpcs.ServeConn(conn)
            pb.done.Done()
          }()
        }
      } else if err == nil {
        conn.Close()
      }
      if err != nil && pb.dead == false {
        fmt.Printf("PBServer(%v) accept: %v\n", me, err.Error())
        pb.kill()
      }
    }
    DPrintf("%s: wait until all request are done\n", pb.me)
    pb.done.Wait() 
    // If you have an additional thread in your solution, you could
    // have it read to the finish channel to hear when to terminate.
    close(pb.finish)
  }()

  pb.done.Add(1)
  go func() {
    for pb.dead == false {
      pb.tick()
      time.Sleep(viewservice.PingInterval)
    }
    pb.done.Done()
  }()

  return pb
}
