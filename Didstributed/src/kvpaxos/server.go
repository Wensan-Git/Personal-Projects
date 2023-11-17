package kvpaxos

import (
	"encoding/gob"
	"fmt"
	"log"
	"math/rand"
	"net"
	"net/rpc"
	"os"
	"paxos"
	"strconv"
	"sync"
	"syscall"
	"time"
)

const Debug=0

func DPrintf(format string, a ...interface{}) (n int, err error) {
  if Debug > 0 {
    log.Printf(format, a...)
  }
  return
}


type Op struct {
  // Your definitions here.
  // Field names must start with capital letters,
  // otherwise RPC will break.
  Key string
  Value string
  Id int64
  Operation string
}

type KVPaxos struct {
  mu sync.Mutex
  l net.Listener
  me int
  dead bool // for testing
  unreliable bool // for testing
  px *paxos.Paxos
  cache map[int64]string
  currSeq int
  dataStore map[string]string

  // Your definitions here.
}


func (kv *KVPaxos) Get(args *GetArgs, reply *GetReply) error {
  kv.mu.Lock()
  defer kv.mu.Unlock()
  if value, exists := kv.cache[args.Id]; exists {
    reply.Value = value
    reply.Err = "OK"
    return nil
  }
  currOp := Op{Key: args.Key, Value: "", Id: args.Id, Operation: "Get"}
  kv.px.Start(kv.currSeq + 1, currOp)
  to := 10 * time.Millisecond
  for {
    // fmt.Printf("hhhhhhhhhhh")
    decided, op := kv.px.Status(kv.currSeq + 1)
    if decided {
      // fmt.Printf("eeeeeeeeee")
      // check if my request succeeded? compare currOp with op
      if currOp == op {
        kv.px.Done(kv.currSeq + 1)
        kv.currSeq ++
        reply.Err = "OK"
        currVal, exists := kv.dataStore[args.Key]
        if exists {
          reply.Value = currVal
          // kv.cache[args.Id] = currVal
        } else {
          reply.Value = ""
          // kv.cache[args.Id] = ""
        }
        return nil
      } else {
        if op.(Op).Operation == "Put" {
          _, exists := kv.dataStore[op.(Op).Key]
          if exists {
            kv.cache[op.(Op).Id] = ""
            kv.dataStore[op.(Op).Key] = op.(Op).Value
          } else {
            kv.cache[op.(Op).Id] = ""
            kv.dataStore[op.(Op).Key] = op.(Op).Value
          }
        } else if op.(Op).Operation == "PutHash" {
          currVal, exists := kv.dataStore[op.(Op).Key]
          if exists {
            kv.cache[op.(Op).Id] = currVal
            strValue := strconv.Itoa(int(hash(currVal + op.(Op).Value)))
            kv.dataStore[op.(Op).Key] = strValue
          } else {
            kv.cache[op.(Op).Id] = currVal
            strValue := strconv.Itoa(int(hash("" + op.(Op).Value)))
            kv.dataStore[op.(Op).Key] = strValue
          }
        }
        kv.px.Done(kv.currSeq + 1)
        kv.currSeq ++
        kv.px.Start(kv.currSeq + 1, currOp)
      }
    }
    time.Sleep(to)
    // if to < 10 * time.Second {
    //   to *= 2
    // }
  }
}

func (kv *KVPaxos) Put(args *PutArgs, reply *PutReply) error {
  kv.mu.Lock()
  defer kv.mu.Unlock()
  if value, exists := kv.cache[args.Id]; exists {
    reply.PreviousValue = value
    reply.Err = "OK"
    return nil
  }
  var operation string
  if args.DoHash {
    operation = "PutHash"
  } else {
    operation = "Put"
  }

  currOp := Op{Key: args.Key, Value: args.Value, Id: args.Id, Operation: operation}
  kv.px.Start(kv.currSeq + 1, currOp)
  to := 10 * time.Millisecond
  for {
    // fmt.Printf("一直跑")
    decided, op := kv.px.Status(kv.currSeq + 1)
    if decided {
      // check if my request succeeded? compare currOp with op
      if currOp == op {
        if currOp.Operation == "Put" {
          currVal, exists := kv.dataStore[op.(Op).Key]
          if exists {
            reply.Err = "OK"
            reply.PreviousValue = currVal
            kv.cache[args.Id] = ""
            kv.dataStore[args.Key] = args.Value
          } else {
            reply.Err = "OK"
            reply.PreviousValue = ""
            kv.cache[args.Id] = ""
            kv.dataStore[args.Key] = args.Value
          }
        } else {
          currVal, exists := kv.dataStore[op.(Op).Key]
          if exists {
            reply.Err = "OK"
            reply.PreviousValue = currVal
            kv.cache[args.Id] = currVal
            strValue := strconv.Itoa(int(hash(currVal + args.Value)))
            kv.dataStore[args.Key] = strValue
          } else {
            reply.Err = "OK"
            reply.PreviousValue = ""
            kv.cache[args.Id] = ""
            strValue := strconv.Itoa(int(hash("" + args.Value)))
            kv.dataStore[args.Key] = strValue
          }
        }
        kv.px.Done(kv.currSeq + 1)
        kv.currSeq ++
        return nil
      } else {
        currVal, exists := kv.dataStore[op.(Op).Key]
        if op.(Op).Operation == "Put" {
          if exists {
            kv.cache[op.(Op).Id] = ""
            kv.dataStore[op.(Op).Key] = op.(Op).Value
          } else {
            kv.cache[op.(Op).Id] = ""
            kv.dataStore[op.(Op).Key] = op.(Op).Value
          }
        } else if op.(Op).Operation == "PutHash" {
          if exists {
            kv.cache[op.(Op).Id] = currVal
            strValue := strconv.Itoa(int(hash(currVal + op.(Op).Value)))
            kv.dataStore[op.(Op).Key] = strValue
          } else {
            kv.cache[op.(Op).Id] = currVal
            strValue := strconv.Itoa(int(hash("" + op.(Op).Value)))
            kv.dataStore[op.(Op).Key] = strValue
          }
        }
        kv.px.Done(kv.currSeq + 1)
        kv.currSeq ++
        kv.px.Start(kv.currSeq + 1, currOp)
      }
    }
    time.Sleep(to)
    // if to < 10 * time.Second {
    //   to *= 2
    // }
  }

}

// tell the server to shut itself down.
// please do not change this function.
func (kv *KVPaxos) kill() {
  DPrintf("Kill(%d): die\n", kv.me)
  kv.dead = true
  kv.l.Close()
  kv.px.Kill()
}

//
// servers[] contains the ports of the set of
// servers that will cooperate via Paxos to
// form the fault-tolerant key/value service.
// me is the index of the current server in servers[].
// 
func StartServer(servers []string, me int) *KVPaxos {
  // call gob.Register on structures you want
  // Go's RPC library to marshall/unmarshall.
  gob.Register(Op{})

  kv := new(KVPaxos)
  kv.me = me
  kv.cache = map[int64]string{}
  kv.dataStore = map[string]string{}
  kv.currSeq = 0

  // Your initialization code here.

  rpcs := rpc.NewServer()
  rpcs.Register(kv)

  kv.px = paxos.Make(servers, me, rpcs)
  // Do a reboot logic to call start on incrementing instances numbers until its not decided anymore
  

  os.Remove(servers[me])
  l, e := net.Listen("unix", servers[me]);
  if e != nil {
    log.Fatal("listen error: ", e);
  }
  kv.l = l


  // please do not change any of the following code,
  // or do anything to subvert it.

  go func() {
    for kv.dead == false {
      conn, err := kv.l.Accept()
      if err == nil && kv.dead == false {
        if kv.unreliable && (rand.Int63() % 1000) < 100 {
          // discard the request.
          conn.Close()
        } else if kv.unreliable && (rand.Int63() % 1000) < 200 {
          // process the request but force discard of reply.
          c1 := conn.(*net.UnixConn)
          f, _ := c1.File()
          err := syscall.Shutdown(int(f.Fd()), syscall.SHUT_WR)
          if err != nil {
            fmt.Printf("shutdown: %v\n", err)
          }
          go rpcs.ServeConn(conn)
        } else {
          go rpcs.ServeConn(conn)
        }
      } else if err == nil {
        conn.Close()
      }
      if err != nil && kv.dead == false {
        fmt.Printf("KVPaxos(%v) accept: %v\n", me, err.Error())
        kv.kill()
      }
    }
  }()

  return kv
}

