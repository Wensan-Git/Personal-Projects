package viewservice

import (
	"fmt"
	"log"
	"net"
	"net/rpc"
	"os"
	// "strconv"
	"sync"
	"time"
)

type ViewServer struct {
  mu sync.Mutex
  l net.Listener
  dead bool
  me string
  lastPing map[string]time.Time
  ackView uint
  currView View
  systemStuck bool


  // Your declarations here.
}

//
// server Ping RPC handler.
//
func (vs *ViewServer) Ping(args *PingArgs, reply *PingReply) error {
  vs.mu.Lock()
  defer vs.mu.Unlock()
  // update the current server in the lastPing tracker map
  vs.lastPing[args.Me] = time.Now()
  // when a higher view number is acknowledge, then update ackView
  if args.Viewnum > vs.ackView && args.Me == vs.currView.Primary {
    vs.ackView = args.Viewnum
  }
  if vs.systemStuck {
    reply.View = vs.currView
    return nil
  }

  // when the ping number is 0
  if args.Viewnum == 0 {
    if vs.currView.Viewnum == 0 {
      vs.currView = View{Viewnum: 1, Primary: args.Me, Backup: ""}
      reply.View = vs.currView
      return nil
    } else { // if there has been primary servers before 
      if args.Me == vs.currView.Primary {
        if vs.currView.Backup != "" {
          if vs.currView.Viewnum == vs.ackView {
            vs.currView = View{Viewnum: vs.currView.Viewnum + 1, Primary: vs.currView.Backup, Backup: ""}
            reply.View = vs.currView
            return nil
          }
        } else {
          vs.systemStuck = true
          reply.View = vs.currView
          return nil
        }
      } else if args.Me == vs.currView.Backup || vs.currView.Backup == "" {
        if vs.currView.Viewnum == vs.ackView {
          vs.currView = View{Viewnum: vs.currView.Viewnum + 1, Primary: vs.currView.Primary, Backup: args.Me}
          reply.View = vs.currView
          return nil
        }
      }
    }
  } else {// when the ping number is not 0
    if vs.currView.Backup == "" {
      if args.Me != vs.currView.Primary{
        if vs.currView.Viewnum == vs.ackView {
          vs.currView = View{Viewnum: vs.currView.Viewnum + 1, Primary: vs.currView.Primary, Backup: args.Me}
          reply.View = vs.currView
          return nil
        }
      }
    }
  }
  reply.View = vs.currView
  return nil
}

// 
// server Get() RPC handler.
//
func (vs *ViewServer) Get(args *GetArgs, reply *GetReply) error {
  reply.View = vs.currView

  return nil
}


//
// tick() is called once per PingInterval; it should notice
// if servers have died or recovered, and change the view
// accordingly.
//
func (vs *ViewServer) tick() {
  vs.mu.Lock()
  defer vs.mu.Unlock()
  if vs.systemStuck {
    return
  }
  if vs.currView.Primary != "" {
    if time.Until(vs.lastPing[vs.currView.Primary]) < -DeadPings * PingInterval {
      if vs.currView.Backup != "" {
        if time.Until(vs.lastPing[vs.currView.Backup]) >= -DeadPings * PingInterval {
          if vs.currView.Viewnum == vs.ackView {
            vs.currView = View{Viewnum: vs.currView.Viewnum + 1, Primary: vs.currView.Backup, Backup: ""}
          } else {
            vs.systemStuck = true
            return
          }
        } else {
          vs.systemStuck = true
          return
        }
      } else {
        vs.systemStuck = true
        return
      }
    }
  }
  if vs.currView.Backup != "" {
    if time.Until(vs.lastPing[vs.currView.Backup]) < -DeadPings * PingInterval {
      for server := range vs.lastPing{
        if time.Until(vs.lastPing[server]) >= -DeadPings * PingInterval && server != vs.currView.Primary { // the server is not dead and it is not primary
          if vs.currView.Viewnum == vs.ackView {
            vs.currView = View{Viewnum: vs.currView.Viewnum + 1, Primary: vs.currView.Primary, Backup: server}
            break
          }
        }
      }
    }
  }
}

//
// tell the server to shut itself down.
// for testing.
// please don't change this function.
//
func (vs *ViewServer) Kill() {
  vs.dead = true
  vs.l.Close()
}

func StartServer(me string) *ViewServer {
  vs := new(ViewServer)
  vs.me = me
  // Your vs.* initializations here.
  vs.lastPing = map[string]time.Time{}
  vs.ackView = 0
  vs.currView = View{Viewnum: 0, Primary: "", Backup: ""}
  vs.systemStuck = false

  // tell net/rpc about our RPC server and handlers.
  rpcs := rpc.NewServer()
  rpcs.Register(vs)

  // prepare to receive connections from clients.
  // change "unix" to "tcp" to use over a network.
  os.Remove(vs.me) // only needed for "unix"
  l, e := net.Listen("unix", vs.me);
  if e != nil {
    log.Fatal("listen error: ", e);
  }
  vs.l = l

  // please don't change any of the following code,
  // or do anything to subvert it.

  // create a thread to accept RPC connections from clients.
  go func() {
    for vs.dead == false {
      conn, err := vs.l.Accept()
      if err == nil && vs.dead == false {
        go rpcs.ServeConn(conn)
      } else if err == nil {
        conn.Close()
      }
      if err != nil && vs.dead == false {
        fmt.Printf("ViewServer(%v) accept: %v\n", me, err.Error())
        vs.Kill()
      }
    }
  }()

  // create a thread to call tick() periodically.
  go func() {
    for vs.dead == false {
      vs.tick()
      time.Sleep(PingInterval)
    }
  }()

  return vs
}
