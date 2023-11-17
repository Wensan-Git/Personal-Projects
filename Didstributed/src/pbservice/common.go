package pbservice

import (
	"hash/fnv"
)

const (
  OK = "OK"
  ErrNoKey = "ErrNoKey"
  ErrWrongServer = "ErrWrongServer"
)
type Err string

type PutArgs struct {
  Key string
  Value string
  DoHash bool // For PutHash
  RequestId int64
  // You'll have to add definitions here.
  // Field names must start with capital letters,
  // otherwise RPC will break.
}

type PutReply struct {
  Err Err
  PreviousValue string // For PutHash
}

type GetArgs struct {
  Key string
  RequestId int64
  // You'll have to add definitions here.
}

type GetReply struct {
  Err Err
  Value string
}

type SyncArgs struct {

}

type SyncReply struct {
  Err Err
  Data map[string]string
  Cache map[int64]string
}

type SendArgs struct {
  Data map[string]string
  Cache map[int64]string
}

type SendReply struct {
  Err Err
}

type CheckSyncArgs struct {

}

type CheckSyncReply struct {
  Synched bool
}

type UpdateSyncArgs struct {

}

type UpdateSyncReply struct {
  Err Err
}

// Your RPC definitions here.
//RPC for forwarding request

// RPC for synching database between primary and backup


func hash(s string) uint32 {
  h := fnv.New32a()
  h.Write([]byte(s))
  return h.Sum32()
}

