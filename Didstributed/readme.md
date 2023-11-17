* [Part 1: MapReduce](instructions/Assignment1.md)
* [Part 2: Primary-Backup Key/Value Service](instructions/Assignment2.md)
* [part 3: Paxos-based Key/Value Service](instructions/Assignment3.md)
* [Part 4: Sharded Key/Value Service](instructions/Assignment4.md)



The first project is a replication of MapReduce functionality and exposes first usage of goroutine and concurrency .Most code contributions are in ./src/mapreduce


The second project begins by making a primary-backup server model for the system to be prune for network error. Most code contributions are in ./src/viewservice and ./src/pbservice


The third project creates the Paxos protocol for concensus reaching and building a system that consistently reaches concensus about new data input. Most code contributions are in ./src/paxos and ./src/kvpaxos

The fourth project creates a sharded paxos protocol to increase the scalability of the system by dividing tasks into shards and assigning different shards to different service groups. Most code contributions are in ./src/shardmaster and ./src/shardkv.
