package shardmaster

import (
	"encoding/gob"
	"fmt"
	"log"
	"math/rand"
	"net"
	"net/rpc"
	"os"
	"paxos"
	"sort"
	"sync"
	"syscall"
	"time"
)

type ShardMaster struct {
	mu         sync.Mutex
	l          net.Listener
	me         int
	dead       bool // for testing
	unreliable bool // for testing
	px         *paxos.Paxos
	currSeq    int
	configs    []Config // indexed by config num
}

type Op struct {
	Optype      string
	RequestId   int64 // what is this for??
	Gid         int64
	ListServers []string
	Shard       int // for move
	QueryNum    int // for query
}

func (sm *ShardMaster) Join(args *JoinArgs, reply *JoinReply) error {
	sm.mu.Lock()
	defer sm.mu.Unlock()
	// make sure I verify what RequestId is for
  // fmt.Printf("yoyo")
	id := nrand()
	currOp := Op{Optype: "join", RequestId: id, Gid: args.GID, ListServers: args.Servers, Shard: 0, QueryNum: 0}
	sm.px.Start(sm.currSeq+1, currOp)
	to := 10 * time.Millisecond
	for {
    // fmt.Printf("hihi")
		decided, op := sm.px.Status(sm.currSeq + 1)
		if decided {
      // fmt.Printf("haha")
			if currOp.RequestId == op.(Op).RequestId {
				sm.JoinLoadBalance(currOp)
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
        return nil
			} else {
				if op.(Op).Optype == "join" {
					sm.JoinLoadBalance(op.(Op))
				} else if op.(Op).Optype == "leave" {
					sm.LeaveLoadBalance(op.(Op))
				} else if op.(Op).Optype == "move" {
					sm.MoveProcedure(op.(Op))
				} 
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
				sm.px.Start(sm.currSeq+1, currOp)
			}
		}
		time.Sleep(to)
	}

}

func (sm *ShardMaster) QueryProcedure(op Op) Config {
  if op.QueryNum < 0 || op.QueryNum >= len(sm.configs) {
    return sm.configs[len(sm.configs) - 1]
  } else {
    return sm.configs[op.QueryNum]
  }
}

func (sm *ShardMaster) MoveProcedure(op Op) error {
	newConfigNum := len(sm.configs)
	prevConfig := sm.configs[newConfigNum-1]
	var shards [len(prevConfig.Shards)]int64
	for index := 0; index < len(prevConfig.Shards); index++ {
		if index == op.Shard {
			shards[index] = op.Gid
		} else {
			shards[index] = prevConfig.Shards[index]
		}
	}
	groups := map[int64][]string{}
	for gid, servers := range prevConfig.Groups {
		var serversCopy []string
		serversCopy = append(serversCopy, servers...)
		groups[gid] = serversCopy
	}
	newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
	sm.configs = append(sm.configs, newConfig)
	return nil
}

func (sm *ShardMaster) LeaveLoadBalance(op Op) error {
	newConfigNum := len(sm.configs)
	prevConfig := sm.configs[newConfigNum-1]
	gitTracker := map[int64][]int{}
  // fmt.Printf("leave, Gid %v, length, %v, me, %v \n", op.Gid, len(prevConfig.Groups), sm.me)
	// put shards into a tracker that maps between gid and a list of shard numbers
	for shard, gid := range prevConfig.Shards {
		if _, exists := gitTracker[gid]; exists {
			gitTracker[gid] = append(gitTracker[gid], shard)
		} else {
			gitTracker[gid] = []int{shard}
		}
	}
  // fmt.Printf("Hola \n")
  // if the Gid to leave does not exist
  if _, exists := gitTracker[op.Gid]; !exists {
    shards := [10]int64{}
    for i := 0; i < 10; i ++ {
      shards[i] = prevConfig.Shards[i]
    }
    groups := map[int64][]string{}
    for gid, servers := range prevConfig.Groups {
      if op.Gid != gid{
        var serversCopy []string
        serversCopy = append(serversCopy, servers...)
        groups[gid] = serversCopy
      }  
    }
    newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
    sm.configs = append(sm.configs, newConfig)
    return nil
  }

  // 将Groups里面没分配Shards的东西也放进来

  for gid, _ := range prevConfig.Groups {
    if _, exists := gitTracker[gid]; !exists {
      gitTracker[gid] = []int{}
    }
  }

	excessiveList := []int{}
	excessiveList = append(excessiveList, gitTracker[op.Gid]...)
	delete(gitTracker, op.Gid)
	// 组织一个gids的list，并且将它们sort出来
	var gids []int64
	for gid := range gitTracker {
		gids = append(gids, gid)
	}
  
  // deal with empty gids list case
  if len(gids) == 0 {
    groups := map[int64][]string{}
    shards := [10]int64{}
    for i := 0; i < 10; i++ {
      shards[i] = 0
    }
    newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
    sm.configs = append(sm.configs, newConfig)
    return nil
  }

  
	minCanHave := len(prevConfig.Shards) / (len(gids))
  maxCanhave := minCanHave
  
  if len(prevConfig.Shards) % len(gids) != 0 {
    maxCanhave++
  }

	// sort the list of gids to guarantee order
	sort.Slice(gids, func(i, j int) bool {
		return gids[i] < gids[j]
	})

	// 创造可以提供shards的group和需要获取shards的group
	gidsMoreThanMax := []int64{}
	gidsLessThanMin := []int64{}
	for _, gid := range gids {
		if len(gitTracker[gid]) >= maxCanhave {
			excessiveList = append(excessiveList, gitTracker[gid][:(len(gitTracker[gid])-maxCanhave)]...)
      gitTracker[gid] = gitTracker[gid][(len(gitTracker[gid])-maxCanhave):]
			gidsMoreThanMax = append(gidsMoreThanMax, gid)
		} else if len(gitTracker[gid]) <= minCanHave {
			gidsLessThanMin = append(gidsLessThanMin, gid)
		}
	}

	// 将excessiveList放入gidsLessThanMin的里面
	for _, gid := range gidsLessThanMin {
		for len(gitTracker[gid]) < minCanHave && len(excessiveList) > 0 {
			gitTracker[gid] = append(gitTracker[gid], excessiveList[0])
			excessiveList = excessiveList[1:]
		}
	}

	// 放不满的情况
	for _, lessGid := range gidsLessThanMin {
		for len(gitTracker[lessGid]) < minCanHave {
			for _, largeGid := range gidsMoreThanMax {
				if len(gitTracker[largeGid]) >= maxCanhave {
					gitTracker[lessGid] = append(gitTracker[lessGid], gitTracker[largeGid][0])
					gitTracker[largeGid] = gitTracker[largeGid][1:]
					break
				}
			}
		}
	}
	// excessive 多了的情况
	for _, excessShard := range excessiveList {
		for _, lessGid := range gidsLessThanMin {
			if len(gitTracker[lessGid]) <= minCanHave {
				gitTracker[lessGid] = append(gitTracker[lessGid], excessShard)
				break
			}
		}
	}

	// The code below forms the final shards
	var shards [len(prevConfig.Shards)]int64
	for _, gid := range gids {
		for _, shard := range gitTracker[gid] {
			shards[shard] = gid
		}
	}

	// The code below forms the final groups
	groups := map[int64][]string{}
	for gid, servers := range prevConfig.Groups {
		if gid != op.Gid {
      // fmt.Printf("hahahhahahhahahhha \n")
			var serversCopy []string
			serversCopy = append(serversCopy, servers...)
			groups[gid] = serversCopy
		}
	}

	newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
	sm.configs = append(sm.configs, newConfig)
  // fmt.Printf("new config upon leave: Gid %v, length %v, me, %v \n", op.Gid, len(newConfig.Groups), sm.me)
	return nil
}

func (sm *ShardMaster) JoinLoadBalance(op Op) error {
  
	newConfigNum := len(sm.configs)
	prevConfig := sm.configs[newConfigNum-1]
  // fmt.Printf("join, Prev: %v, length %v, me, %v", prevConfig.Groups, len(prevConfig.Groups), sm.me)
	// if this is the first join
	if prevConfig.Shards[0] == 0 {
		var shards [len(prevConfig.Shards)]int64
		for i := range shards {
			shards[i] = op.Gid
		}
		groups := map[int64][]string{}
		groups[op.Gid] = op.ListServers
		newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
		sm.configs = append(sm.configs, newConfig)
    // fmt.Printf("new config: %v", newConfig.Shards)
		// if this is not the first join
	} else {
		gitTracker := map[int64][]int{}
		// put shards into a tracker that maps between gid and a list of shard numbers
		for shard, gid := range prevConfig.Shards {
			if _, exists := gitTracker[gid]; exists {
				gitTracker[gid] = append(gitTracker[gid], shard)
			} else {
				gitTracker[gid] = []int{shard}
			}
		}

    // check if new gid already exists:
    if _, exists := gitTracker[op.Gid]; exists {
      shards := [10]int64{}
      for i := 0; i < 10; i ++ {
        shards[i] = prevConfig.Shards[i]
      }
      groups := map[int64][]string{}
      for gid, servers := range prevConfig.Groups {
        if op.Gid == gid {
          groups[gid] = op.ListServers
        } else {
          var serversCopy []string
          serversCopy = append(serversCopy, servers...)
          groups[gid] = serversCopy
        }
      }
      newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
      sm.configs = append(sm.configs, newConfig)
      return nil
    }

		// 组织一个gids的list，并且将它们sort出来
		var gids []int64
		for gid := range gitTracker {
			gids = append(gids, gid)
		}
		// 此处放入新的args.Gid
		gids = append(gids, op.Gid)
    
		minCanHave := len(prevConfig.Shards) / (len(gids))
		maxCanhave := minCanHave
    
		if len(prevConfig.Shards) % len(gids) != 0 {
			maxCanhave++
		}
    // fmt.Printf("%v", maxCanhave)
		// sort the list of gids to guarantee order
		sort.Slice(gids, func(i, j int) bool {
			return gids[i] < gids[j]
		})

		shardsForNewGid := []int{}
		gitTracker[op.Gid] = shardsForNewGid
		// 这里加入我ipad加入的logic
		// ADD Code HERE
		excessiveList := []int{}
		gidsMoreThanMax := []int64{}
		gidsLessThanMin := []int64{}
		for _, gid := range gids {
			if len(gitTracker[gid]) >= maxCanhave {
				excessiveList = append(excessiveList, gitTracker[gid][:(len(gitTracker[gid])-maxCanhave)]...)
        gitTracker[gid] = gitTracker[gid][(len(gitTracker[gid])-maxCanhave):]
				gidsMoreThanMax = append(gidsMoreThanMax, gid)
			} else if len(gitTracker[gid]) <= minCanHave {
				gidsLessThanMin = append(gidsLessThanMin, gid)
			}
		}
    
		// 将excessiveList放入gidsLessThanMin的里面
		for _, gid := range gidsLessThanMin {
			for len(gitTracker[gid]) < minCanHave && len(excessiveList) > 0 {
				gitTracker[gid] = append(gitTracker[gid], excessiveList[0])
				excessiveList = excessiveList[1:]
			}
		}
    // fmt.Printf("after: %v", gitTracker[op.Gid])
		// 放不满的情况
		for _, lessGid := range gidsLessThanMin {
			for len(gitTracker[lessGid]) < minCanHave {
				for _, largeGid := range gidsMoreThanMax {
					if len(gitTracker[largeGid]) >= maxCanhave {
						gitTracker[lessGid] = append(gitTracker[lessGid], gitTracker[largeGid][0])
						gitTracker[largeGid] = gitTracker[largeGid][1:]
						break
					}
				}
			}
		}
		// excessive 多了的情况
		for _, excessShard := range excessiveList {
			for _, lessGid := range gidsLessThanMin {
				if len(gitTracker[lessGid]) <= minCanHave {
					gitTracker[lessGid] = append(gitTracker[lessGid], excessShard)
					break
				}
			}
		}

		// The code below forms the final shards
		var shards [len(prevConfig.Shards)]int64
		for _, gid := range gids {
			for _, shard := range gitTracker[gid] {
				shards[shard] = gid
			}
		}
		// the code below forms the final groups
		groups := map[int64][]string{}
		for gid, servers := range prevConfig.Groups {
			var serversCopy []string
			serversCopy = append(serversCopy, servers...)
			groups[gid] = serversCopy
		}
		groups[op.Gid] = op.ListServers
		newConfig := Config{Num: newConfigNum, Shards: shards, Groups: groups}
		sm.configs = append(sm.configs, newConfig)
    // fmt.Printf("new config: %v, length %v, me, %v", newConfig.Groups, len(newConfig.Groups), sm.me)
	}
  
	return nil
}

func (sm *ShardMaster) Leave(args *LeaveArgs, reply *LeaveReply) error {
	sm.mu.Lock()
	defer sm.mu.Unlock()
	// make sure I verify what RequestId is for
	id := nrand()
	currOp := Op{Optype: "leave", RequestId: id, Gid: args.GID, ListServers: []string{}, Shard: 0, QueryNum: 0}
	sm.px.Start(sm.currSeq+1, currOp)
	to := 10 * time.Millisecond
	for {
		decided, op := sm.px.Status(sm.currSeq + 1)
		if decided {
			if currOp.RequestId == op.(Op).RequestId {
				sm.LeaveLoadBalance(currOp)
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
        return nil
			} else {
				if op.(Op).Optype == "join" {
					sm.JoinLoadBalance(op.(Op))
				} else if op.(Op).Optype == "leave" {
					sm.LeaveLoadBalance(op.(Op))
				} else if op.(Op).Optype == "move" {
					sm.MoveProcedure(op.(Op))
				} 
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
				sm.px.Start(sm.currSeq+1, currOp)
			}
		}
		time.Sleep(to)
	}
}

func (sm *ShardMaster) Move(args *MoveArgs, reply *MoveReply) error {
	sm.mu.Lock()
	defer sm.mu.Unlock()
	// make sure I verify what RequestId is for
	id := nrand()
	currOp := Op{Optype: "move", RequestId: id, Gid: args.GID, ListServers: []string{}, Shard: args.Shard, QueryNum: 0}
	sm.px.Start(sm.currSeq+1, currOp)
	to := 10 * time.Millisecond
	for {
		decided, op := sm.px.Status(sm.currSeq + 1)
		if decided {
			if currOp.RequestId == op.(Op).RequestId {
				sm.MoveProcedure(currOp)
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
        return nil
			} else {
				if op.(Op).Optype == "join" {
					sm.JoinLoadBalance(op.(Op))
				} else if op.(Op).Optype == "leave" {
					sm.LeaveLoadBalance(op.(Op))
				} else if op.(Op).Optype == "move" {
					sm.MoveProcedure(op.(Op))
				} 
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
				sm.px.Start(sm.currSeq+1, currOp)
			}
		}
		time.Sleep(to)
	}
}

func (sm *ShardMaster) Query(args *QueryArgs, reply *QueryReply) error {
	sm.mu.Lock()
	defer sm.mu.Unlock()
	// make sure I verify what RequestId is for
	id := nrand()
	currOp := Op{Optype: "query", RequestId: id, Gid: 0, ListServers: []string{}, Shard: 0, QueryNum: args.Num}
	sm.px.Start(sm.currSeq+1, currOp)
	to := 10 * time.Millisecond
	for {
		decided, op := sm.px.Status(sm.currSeq + 1)
		if decided {
			if currOp.RequestId == op.(Op).RequestId {
				returnedConfig := sm.QueryProcedure(currOp)
        // fmt.Printf("hihi")
        reply.Config = returnedConfig
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
        return nil
			} else {
				if op.(Op).Optype == "join" {
					sm.JoinLoadBalance(op.(Op))
				} else if op.(Op).Optype == "leave" {
					sm.LeaveLoadBalance(op.(Op))
				} else if op.(Op).Optype == "move" {
					sm.MoveProcedure(op.(Op))
				} 
				sm.px.Done(sm.currSeq + 1)
				sm.currSeq++
				sm.px.Start(sm.currSeq+1, currOp)
			}
		}
		time.Sleep(to)
	}
}

// please don't change this function.
func (sm *ShardMaster) Kill() {
	sm.dead = true
	sm.l.Close()
	sm.px.Kill()
}

// servers[] contains the ports of the set of
// servers that will cooperate via Paxos to
// form the fault-tolerant shardmaster service.
// me is the index of the current server in servers[].
func StartServer(servers []string, me int) *ShardMaster {
	gob.Register(Op{})

	sm := new(ShardMaster)
	sm.me = me

	sm.configs = make([]Config, 1)
	sm.configs[0].Groups = map[int64][]string{}
  sm.configs[0].Num = 0
  sm.configs[0].Shards = [10]int64{}
  for i := 0; i < 10; i++ {
    sm.configs[0].Shards[i] = 0
  }
  sm.currSeq = 0

	rpcs := rpc.NewServer()
	rpcs.Register(sm)

	sm.px = paxos.Make(servers, me, rpcs)

	os.Remove(servers[me])
	l, e := net.Listen("unix", servers[me])
	if e != nil {
		log.Fatal("listen error: ", e)
	}
	sm.l = l

	// please do not change any of the following code,
	// or do anything to subvert it.

	go func() {
		for sm.dead == false {
			conn, err := sm.l.Accept()
			if err == nil && sm.dead == false {
				if sm.unreliable && (rand.Int63()%1000) < 100 {
					// discard the request.
					conn.Close()
				} else if sm.unreliable && (rand.Int63()%1000) < 200 {
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
			if err != nil && sm.dead == false {
				fmt.Printf("ShardMaster(%v) accept: %v\n", me, err.Error())
				sm.Kill()
			}
		}
	}()

	return sm
}
