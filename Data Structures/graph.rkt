#lang dssl2

let eight_principles = ["Know your rights.", "Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
# HW4: Graph
#
# ** You must work on your own for this assignment. **

import cons
import 'hw4-lib/dictionaries.rkt'
import sbox_hash


###
### REPRESENTATION
###

# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]

# A weighted, undirected graph ADT.
interface WU_GRAPH:

    # Returns the number of vertices in the graph. (The vertices
    # are numbered 0, 1, ..., k - 1.)
    def len(self) -> nat?

    # Sets the weight of the edge between u and v to be w. Passing a
    # real number for w updates or adds the edge to have that weight,
    # whereas providing providing None for w removes the edge if
    # present. (In other words, this operation is idempotent.)
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC

    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?

    # Gets a list of all vertices adjacent to v. (The order of the
    # list is unspecified.)
    def get_adjacent(self, v: Vertex?) -> VertexList?

    # Gets a list of all edges in the graph, in an unspecified order.
    # This list only includes one direction for each edge. For
    # example, if there is an edge of weight 10 between vertices
    # 1 and 3, then exactly one of WEdge(1, 3, 10) or WEdge(3, 1, 10)
    # will be in the result list, but not both.
    def get_all_edges(self) -> WEdgeList?


### This will be an adjacency matrix representation, which is an array of arrays.
### Each array is of "size" long
class WuGraph (WU_GRAPH):
### ^ YOUR FIELDS HERE
    let vertex_num
    let graph
    

    def __init__(self, size: nat?):
        self.vertex_num = size
        self.graph = [None; size]
        for i in range(size):
            self.graph[i] = [None;size]
        
        

    def len(self):
        return self.vertex_num

    def set_edge(self, u, v, weight):
        if not weight == None:
            self.graph[u][v] = weight
            self.graph[v][u] = weight
        else:
            self.graph[u][v] = None
            self.graph[v][u] = None
        
    def get_edge(self, u, v):
        return self.graph[u][v]

    def get_adjacent(self, v):
        let adjacent = None
        for i in range(self.vertex_num):
            if self.graph[v][i] is not None:
                adjacent = cons(i,adjacent)
        return adjacent


    def get_all_edges(self):
        let all = None
        for i in range(self.vertex_num):
            for j in range(i, self.vertex_num):
                if not self.graph[i][j] == None:
                    all = cons(WEdge(i, j, self.graph[i][j]), all)
        return all


###
### List helpers
###

# For testing functions that return lists, we provide a function for
# constructing a list from a vector, and functions for sorting (since
# the orders of returned lists are not determined).

# list : VecOf[X] -> ListOf[X]
# Makes a linked list from a vector.
def list(v: vec?) -> Cons.list?:
    return Cons.from_vec(v)

# sort_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def sort_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# sort_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically
# ASSUMPTION: There's no need to compare weights because
# the same edge can’t appear with different weights.
def sort_edges(lst: Cons.list?) -> Cons.list?:
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    return Cons.sort[WEdge?](edge_lt?, lst)

###
### BUILDING GRAPHS
###

def example_graph() -> WuGraph?:
    let result = WuGraph(6) # 6-vertex graph from the assignment
    result.set_edge(0, 1, 12)
    result.set_edge(1, 2, 31)
    result.set_edge(1, 3, 56)
    result.set_edge(4, 2, -2)
    result.set_edge(3, 4, 9)
    result.set_edge(5, 2, 7)
    result.set_edge(3, 5, 1)
    
    return result

struct CityMap:
    let graph
    let city_name_to_node_id
    let node_id_to_city_name

def my_neck_of_the_woods():
    let graph = WuGraph(6)
    let c_to_id = HashTable(6, make_sbox_hash())
    let id_to_c = HashTable(6, make_sbox_hash())
    graph.set_edge(0, 1, 10)
    graph.set_edge(0, 2, 50)
    graph.set_edge(1, 3, 40)
    graph.set_edge(0, 3, 80)
    graph.set_edge(4, 5, 15)
    graph.set_edge(0, 0, 0)
    c_to_id.put("Yantai", 0)
    c_to_id.put("Rongcheng", 1)
    c_to_id.put("Weihai", 2)
    c_to_id.put("Qingdao", 3)
    c_to_id.put("Weifang", 4)
    c_to_id.put("Laiyang", 5)
    id_to_c.put(0, "Yantai")
    id_to_c.put(1, "Rongcheng")
    id_to_c.put(2, "Weihai")
    id_to_c.put(3, "Qingdao")
    id_to_c.put(4, "Weifang")
    id_to_c.put(5, "Laiyang")
    return CityMap(graph, c_to_id, id_to_c)
    
    
test "example_graph":
    let e = example_graph()
    assert e.len() == 6
    assert e.get_edge(4,5) == None
    assert e.get_edge(0,1) == 12
    assert e.get_edge(1,5) == None
    assert e.get_edge(2,5) == 7
    assert e.get_edge(4,3) == 9
    assert e.get_edge(3,1) == 56
    e.set_edge(2,5,8)
    assert e.get_edge(2,5) == 8
    e.set_edge(2,5,None)
    assert e.get_edge(2,5) == None
    e.set_edge(4,5,None)
    assert e.get_edge(4,5) == None
    assert sort_vertices(e.get_adjacent(1)) == cons(0, cons(2, cons(3, None)))
    let adjacent_vector = list ([3])
    let sorted_adjacent_vector = sort_vertices(adjacent_vector)
    assert sort_vertices(e.get_adjacent(5)) == sorted_adjacent_vector
    let vector = list([WEdge(0,1,12),WEdge(1,2,31),WEdge(1,3,56),WEdge(3,5,1), \  
            WEdge(2,4,-2), WEdge(3,4,9)])
    let sorted_vector = sort_edges(vector)
    assert sort_edges(e.get_all_edges()) == sorted_vector
    
    
test "my_city":
    let c = my_neck_of_the_woods()
    let graph = c.graph
    assert graph.len() == 6
    assert graph.get_edge(1,2) == None
    assert graph.get_edge(2,1) == None
    assert graph.get_edge(0,1) == 10
    assert graph.get_edge(1,4) == None
    assert graph.get_edge(3,0) == 80
    assert graph.get_edge(0,0) == 0
    let name_to_id = c.city_name_to_node_id
    assert graph.get_edge(name_to_id.get("Yantai"), name_to_id.get("Weihai")) == 50
    assert graph.get_edge(name_to_id.get("Qingdao"), name_to_id.get("Weifang")) == None
    graph.set_edge(3,1, 50)
    assert graph.get_edge(1,3) == 50
    graph.set_edge(1,3, None)
    assert graph.get_edge(3,1) == None
    let adjacent_vector = list ([0,1,2,3])
    let sorted_adjacent_vector = sort_vertices(adjacent_vector)
    assert sort_vertices(graph.get_adjacent(0)) == sorted_adjacent_vector  ### refers to a component of struct
    let vector = list([WEdge(0,0,0),WEdge(0,1,10),WEdge(0,2,50),WEdge(0,3,80),WEdge(4,5,15)])  
    let sorted_vector = sort_edges(vector)
    assert sort_edges(graph.get_all_edges()) == sorted_vector
    
    
test "empty_buildup_graph":
    let g = WuGraph(6)
    assert g.len() == 6
    assert g.get_all_edges() == None
    assert g.get_adjacent(3) == None
    assert g.get_edge(1,3) == None
    g.set_edge(0,1,4)
    g.set_edge(1,2,3)
    assert g.get_edge(1,2) == 3
    g.set_edge(1,3,5)
    g.set_edge(1,2,5)
    assert g.get_edge(1,2) == 5
    let adjacent_vector = list ([1])
    let sorted_adjacent_vector = sort_vertices(adjacent_vector)
    assert sort_vertices(g.get_adjacent(3)) == sorted_adjacent_vector
    let vector = list([WEdge(0,1,4),WEdge(1,3,5),WEdge(1,2,5)])
    let sorted_vector = sort_edges(vector)
    assert sort_edges(g.get_all_edges()) == sorted_vector
    

    
### create an empty graph and add edges one by one
    
test "no_vertex":
    let g = WuGraph(0)
    assert g.len() == 0
    assert_error g.set_edge(0,0,1)
    assert_error g.get_edge(0,0)
    
  
    
###
### DFS
###

# dfs : WU_GRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WU_GRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    let preds = [False; graph.len()]

    def helper(pred, v):
        if preds[v] == False:
            preds[v] = pred
            f(v)                 
            let successors = graph.get_adjacent(v)
            while successors is not None:
                let successor = successors.data
                successors = successors.next
                helper(v,successor)
    
    helper(start, start)                                  
            
             
# dfs_to_list : WU_GRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
#
# This function uses your `dfs` function to build a list in the
# order of the search. It will pass the test below if your dfs visits
# each reachable vertex once, regardless of the order in which it calls
# `f` on them. However, you should test it more thoroughly than that
# to make sure it is calling `f` (and thus exploring the graph) in
# a correct order.
def dfs_to_list(graph: WU_GRAPH!, start: Vertex?) -> VertexList?:
    let builder = Cons.Builder()
    dfs(graph, start, builder.snoc)
    return builder.take()

    
    ### aliasing array of arrays.
    ## dictionary implemented correctly? is it the most efficient possible?
    ### just a function, or a class method? 
    ### how to make the stack??
    ## assuming reachable, so one connected component? 
    ## is calling f on v just f(v)? nothing else we need to do to call f?
    ## recursion or the non-recursion version?
    
###
### TESTING
###

## You should test your code thoroughly. Here is one test to get you started:

test 'dfs_to_list(example_graph())':
    assert sort_vertices(dfs_to_list(example_graph(), 0)) \
        == list([0, 1, 2, 3, 4, 5])
    assert dfs_to_list(example_graph(), 1) == list([1,3,5,2,4,0])
    assert dfs_to_list(example_graph(), 3) == list([3,5,2,4,1,0])
    assert dfs_to_list(my_neck_of_the_woods().graph,0) == list([0,3,1,2])
    assert dfs_to_list(my_neck_of_the_woods().graph,4) == list([4,5])
    
    assert sort_vertices(dfs_to_list(my_neck_of_the_woods().graph, 0)) \
        == list([0, 1, 2, 3])
    let g = WuGraph(6)
    assert dfs_to_list(g,0) == list([0])
    g.set_edge(0,1,1)
    g.set_edge(0,2,2)
    assert dfs_to_list(g,0) == list([0,2,1])

    
test "dfs_function":
    let sum = 0
    def add_to(v):
        sum = sum + v
    dfs(example_graph(),1, add_to)
    assert sum == 15

test "another_dfs_function":
    let sum = 0
    def add_to(v):
        sum = sum + v
    dfs(my_neck_of_the_woods().graph,1, add_to)
    assert sum == 6
    dfs(my_neck_of_the_woods().graph,4, add_to)
    assert sum == 15

    

    