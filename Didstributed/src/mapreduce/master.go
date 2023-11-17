package mapreduce

import (
	"container/list"
	"fmt"
)

type WorkerInfo struct {
  address string
  // You can add definitions here.
}


// Clean up all workers by sending a Shutdown RPC to each one of them Collect
// the number of jobs each work has performed.
func (mr *MapReduce) KillWorkers() *list.List {
  l := list.New()
  for _, w := range mr.Workers {
    DPrintf("DoWork: shutdown %s\n", w.address)
    args := &ShutdownArgs{}
    var reply ShutdownReply;
    ok := call(w.address, "Worker.Shutdown", args, &reply)
    if ok == false {
      fmt.Printf("DoWork: RPC %s shutdown error\n", w.address)
    } else {
      l.PushBack(reply.Njobs)
    }
  }
  return l
}

func (mr *MapReduce) RunMaster() *list.List {

  jobCount := 0
  workerCount := 0
  workerCountAddess := &workerCount
  go func(count *int){
    for ele := range mr.registerChannel{
        mr.availableWorkers <- ele
        *workerCountAddess += 1
    }
  }(workerCountAddess)

  go func() {
    mr.pendingMaps <- 0
  }()

  
  for job := range mr.pendingMaps{
    go func(jobNum int) {
      worker := <- mr.availableWorkers
      var reply DoJobReply
      args := DoJobArgs{File: mr.file, Operation: "Map", JobNumber: jobNum, NumOtherPhase: mr.nReduce}
      ok:= call(worker, "Worker.DoJob", args, &reply)
      if ok && reply.OK {
        mr.finishedMaps += 1
        go func(){
          mr.availableWorkers <- worker
        }()
        if mr.finishedMaps == mr.nMap {
          close(mr.pendingMaps)
          return
        }
        if len(mr.pendingMaps) == 0 {
          go func(){
            jobCount += 1
            mr.pendingMaps <- jobCount
          }()   
        }
      } else {
        mr.pendingMaps <- jobNum
      }
    }(job)
  }

  jobCount = 0
  go func() {
    mr.pendingReduces <- 0
  }()
  for job := range mr.pendingReduces{
    go func(jobNum int) {
      worker := <- mr.availableWorkers
      var reply DoJobReply
      args := DoJobArgs{File: mr.file, Operation: "Reduce", JobNumber: jobNum, NumOtherPhase: mr.nMap}
      ok:= call(worker, "Worker.DoJob", args, &reply)
      if ok && reply.OK {
        mr.finishedReduces += 1
        go func(){
          mr.availableWorkers <- worker
        }()
        if mr.finishedReduces == mr.nReduce {
          close(mr.pendingReduces)
          // close(mr.registerChannel)
          // close(mr.availableWorkers)
          return
        }
        if len(mr.pendingMaps) == 0 {
          go func(){
            jobCount += 1
            mr.pendingReduces <- jobCount
          }()
          
        }
      } else {
        mr.pendingReduces <- jobNum
      }
    }(job)
  }

  return mr.KillWorkers()
}