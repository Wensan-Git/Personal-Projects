#lang dssl2

let eight_principles = ["Know your rights.", "Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

# Final project: Trip Planner
#
# ** You must work on your own for this assignment. **

# Your program will most likely need a number of data structures, many of
# which you've implemented in previous homeworks.
# We have provided you with compiled versions of homework 3, 4, and 5 solutions.
# You can import them as described in the handout.
# Be sure to extract `project-lib.zip` is the same directory as this file.
# You may also import libraries from the DSSL2 standard library (e.g., cons,
# array, etc.).
# Any other code (e.g., from lectures) you wish to use must be copied to this
# file.

import cons
import sbox_hash
import 'project-lib/dictionaries.rkt'
import 'project-lib/stack-queue.rkt'
import 'project-lib/binheap.rkt'
import 'project-lib/graph.rkt'

### Basic Vocabulary Types ###

#  - Latitudes and longitudes are numbers:
let Lat?  = num?
let Lon?  = num?
#  - Point-of-interest categories and names are strings:
let Cat?  = str?
let Name? = str?

# ListC[T] is a list of `T`s (linear time):
let ListC = Cons.ListC

# List of unspecified element type (constant time):
let List? = Cons.list?


### Input Types ###

#  - a SegmentVector  is VecC[SegmentRecord]
#  - a PointVector    is VecC[PointRecord]
# where
#  - a SegmentRecord  is [Lat?, Lon?, Lat?, Lon?]
#  - a PointRecord    is [Lat?, Lon?, Cat?, Name?]


### Output Types ###

#  - a NearbyList     is ListC[PointRecord]; i.e., one of:
#                       - None
#                       - cons(PointRecord, NearbyList)
#  - a PositionList   is ListC[Position]; i.e., one of:
#                       - None
#                       - cons(Position, PositionList)
# where
#  - a PointRecord    is [Lat?, Lon?, Cat?, Name?]  (as above)
#  - a Position       is [Lat?, Lon?]


# Interface for trip routing and searching:
interface TRIP_PLANNER:
    # Finds the shortest route, if any, from the given source position
    # (latitude and longitude) to the point-of-interest with the given
    # name. (Returns the empty list (`None`) if no path can be found.)
    def find_route(
            self,
            src_lat:  Lat?,     # starting latitude
            src_lon:  Lon?,     # starting longitude
            dst_name: Name?     # name of goal
        )   ->        List?     # path to goal (PositionList)

    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position. (Ties for nearest are broken
    # arbitrarily.)
#    def find_nearby(
#            self,
#            src_lat:  Lat?,     # starting latitude
#            src_lon:  Lon?,     # starting longitude
#            dst_cat:  Cat?,     # point-of-interest category
#            n:        nat?      # maximum number of results
#        )   ->        List?     # list of nearby POIs (NearbyList)

    
        
        
struct position:
    let Lat : num?
    let Lon : num?

struct POI:
    let Lat : num?
    let Lon : num?
    let Cat : str?
    let Name : str?
    
struct node:
    let distance : num?
    let node_id: nat?
    
struct dist_node_name:
    let distance : num?
    let node_name
        
class TripPlanner (TRIP_PLANNER):
    let road_map ### a WU graph, containing the road network (including nodes that are isolated)
    let places ### a dictionary, the key is place name, the value is the struct of that place
    let place_name_to_position ### a dictionary, the key is place name, value is position
    let node_id_to_position ### a vector (serving as dictionary) whose position acts as the node_id and the value is a position struct 
    let position_to_node_id ### a dictionary whose key is position and value is a node_id
    let total_roads
    let category_to_place_name
    
    def __init__(self, road_map, point_record):
        self.total_roads = road_map.len()
        
        ### store all the places as a dictionary of place structs
        self.places = HashTable(point_record.len(), make_sbox_hash())
        self.place_name_to_position = HashTable(point_record.len(), make_sbox_hash())
        self.category_to_place_name = HashTable(point_record.len(), make_sbox_hash())
        for p_d in point_record:
            let lat = p_d[0]
            let lon = p_d[1]
            let cat = p_d[2]
            let name = p_d[3]
            let poi = POI(lat, lon, cat, name)
            self.places.put(name, poi)
            let pos = position(lat, lon)
            self.place_name_to_position.put(name, pos)
            if not self.category_to_place_name.mem?(cat):
                self.category_to_place_name.put(cat, cons(name, None))
            else:
                let existing = self.category_to_place_name.get(cat)
                self.category_to_place_name.put(cat, cons(name, existing))
            
            
        
        
        
        ### create a dictionary that maps position to node_id in the road map graph
        self.position_to_node_id = HashTable(point_record.len() + 2*road_map.len(), make_sbox_hash())
        self.node_id_to_position = [None; point_record.len() + 2*road_map.len()]
        let node_id = 0
        for road in road_map:
            let p1 = position(road[0], road[1])
            let p2 = position(road[2], road[3])
            if not self.position_to_node_id.mem?(p1):
                self.position_to_node_id.put(p1, node_id)
                self.node_id_to_position[node_id] = p1
                node_id = node_id + 1
            if not self.position_to_node_id.mem?(p2):
                self.position_to_node_id.put(p2, node_id)
                self.node_id_to_position[node_id] = p2
                node_id = node_id + 1
        for place in point_record:
            let p3 = position(place[0],place[1])
            if not self.position_to_node_id.mem?(p3):
                self.position_to_node_id.put(p3, node_id)
                self.node_id_to_position[node_id] = p3
                node_id = node_id + 1
        
        ### setting the road_map to be a graph with connections
        self.road_map = WuGraph(self.node_id_to_position.len())
        for road in road_map:
             let p1 = position(road[0], road[1])
             let p2 = position(road[2], road[3])
             let distance = ((road[0]-road[2])*(road[0]-road[2])+(road[1]-road[3])*(road[1]-road[3])).sqrt()
             self.road_map.set_edge(self.position_to_node_id.get(p1),self.position_to_node_id.get(p2), distance)

        
    def find_route_vector(self, start_position):
        let start_node = self.position_to_node_id.get(start_position)
        let dist = [inf; self.road_map.len()]
        let pred = [None; self.road_map.len()]
        dist[start_node] = 0
        pred[start_node] = start_node       ####
        let todo = BinHeap(self.total_roads, λ x, y: x.distance < y.distance)  ### x, y are node structs, with distance representing their distance
        let done = [False; self.road_map.len()]
        todo.insert(node(dist[start_node],start_node))
        while todo.len() != 0:
            let current_min = todo.find_min()
            let current_min_node = current_min.node_id
            todo.remove_min()
            if not done[current_min_node]:
                done[current_min_node] = True
                let successors = self.road_map.get_adjacent(current_min_node)
                while successors is not None:
                    let successor = successors.data
                    let additional_distance = self.road_map.get_edge(current_min_node, successor)
                    if dist[current_min_node] + additional_distance < dist[successor]:
                        dist[successor] = dist[current_min_node] + additional_distance
                        pred[successor] = current_min_node
                        todo.insert(node(dist[successor],successor))
                    successors = successors.next                                                    
        return [pred, dist]
            
        
        
    def find_route(self, start_lat, start_lon, point_of_interest):
            let start_position = position(start_lat, start_lon)
            let start_node = self.position_to_node_id.get(start_position)
            let pred_tracer = self.find_route_vector(start_position)[0]
            if not self.position_to_node_id.mem?(start_position):
                return None
            if not self.places.mem?(point_of_interest):
                return None
            let interested_posn = self.place_name_to_position.get(point_of_interest)
            if pred_tracer[self.position_to_node_id.get(interested_posn)] == None:
                return None
            else:
                let queue = ListQueue()
                let current = self.position_to_node_id.get(interested_posn)
                queue.enqueue(current)
                while pred_tracer[current] != start_node:
                    queue.enqueue(pred_tracer[current])
                    current = pred_tracer[current] ###
                queue.enqueue(start_node)
                let route = None
                while not queue.empty?():
                    let previous_id = queue.dequeue()
                    let previous_position_struct = self.node_id_to_position[previous_id]
                    let previous_position = [previous_position_struct.Lat,previous_position_struct.Lon]
                    route = cons(previous_position,route)
                if route.data == [interested_posn.Lat,interested_posn.Lon]:
                    route = route.next
                return route
        
    def find_nearby(self, starting_lat, starting_lon, interested_category, limit):
        if not self.category_to_place_name.mem?(interested_category):
            return None
        let category_list = self.category_to_place_name.get(interested_category)    #### a linked list of category-place pair corresponding to a category
        let start_position = position(starting_lat, starting_lon)
        if not self.position_to_node_id.mem?(start_position):
            return None
        let start_node = self.position_to_node_id.get(start_position)
        let distance_vec = self.find_route_vector(start_position)[1]    #### a vector representing how far each node_id is to the starting point. 
        let Sorting_Binheap = BinHeap(self.places.len(),λ x, y: x.distance < y.distance )
        while category_list != None:
            let node_id = self.position_to_node_id.get(self.place_name_to_position.get(category_list.data))
            let dist_from_starter = distance_vec[node_id]
            let node_name_pair = [node_id,category_list.data]
            let binheap_struct = dist_node_name(dist_from_starter, node_name_pair)
            Sorting_Binheap.insert(binheap_struct)
            category_list = category_list.next
        let curr = limit
        let rec_reverse = None
        while curr != 0:
            if Sorting_Binheap.len() != 0:
                let recommendation = Sorting_Binheap.find_min().node_name[1]
                let recommendation_distance = Sorting_Binheap.find_min().distance
                if not recommendation_distance == inf:
                
                    Sorting_Binheap.remove_min()
                    rec_reverse = cons(recommendation, rec_reverse)
            curr = curr - 1
        let rec = None    
        while rec_reverse != None:
            if not rec_reverse.data == None:
                let correct_name = rec_reverse.data
                let correct_position_lat = self.place_name_to_position.get(correct_name).Lat
                let correct_position_lon = self.place_name_to_position.get(correct_name).Lon
                let correct_format = [correct_position_lat, correct_position_lon, interested_category, correct_name]               ### everything in correct format
                rec = cons(correct_format, rec)
            rec_reverse = rec_reverse.next
        return rec

def my_first_example():
    return TripPlanner([[0,0, 0,1], [0,0, 1,0]],
                       [[0,0, "bar", "The Empty Bottle"],
                        [0,1, "food", "Pelmeni"], [0,2, "bar", "Happy"]])

test 'My first find_route test':
   assert my_first_example().find_route(0, 0, "Pelmeni") == \
       cons([0,0], cons([0,1], None))
   assert my_first_example().find_route(0, 0, "Eating") == None
   assert my_first_example().find_route(1, 0, "Pelmeni") == cons([1,0], cons([0,0],cons([0,1] ,None)))
   assert my_first_example().find_route(0, 0, "Happy") == None
   assert my_first_example().find_route(0, 0, "The Empty Bottle") == cons([0, 0], None)
   assert my_first_example().find_route(0, 2, "Happy") == cons([0, 2], None)

test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == \
        cons([0,1, "food", "Pelmeni"], None)
    assert my_first_example().find_nearby(0, 2, "bar", 2) == \
        cons([0,2, "bar", "Happy"], None)
    

def example_from_handout():
    return TripPlanner([[0,0,0,1],[0,0,1,0],[1,0,1,1],[0,1,1,1],[0,1,0,2], \
        [1,1,1,2], [1,2,0,2], [1,3,1,2], [1,3,-0.2,3.3]],[[0,0,"food", "Sandwiches"], \
         [0,1, "food", "Pasta"], [1,1, "bank", "Local Credit Union"], [1,3, "bar", "Bar None"], \
         [1,3,"bar", "H Bar"], [-0.2, 3.3, "food", "Burritos"]])
         
         
test "Example find_route test":
    let e = example_from_handout()
    assert e.find_route(0,0,"Sandwiches") == cons([0,0],None)
    assert e.find_route(0,1,"Sandwiche") == None
    assert e.find_route(0,0,"Local Credit Union") == cons([0, 0],cons([1, 0],cons([1, 1], None)))
    assert e.find_route(1,1,"Burritos") == cons([1, 1],cons([1, 2],cons([1, 3], cons([-0.2, 3.3],None))))
    assert e.find_route(1,3, "H Bar") == cons([1,3],None)
    assert e.find_route(0,1, "Bar None") == cons([0, 1],cons([0, 2],cons([1, 2], cons([1, 3],None))))
    
    assert e.find_route(-0.2,3.3, "Sandwiches") == cons([-0.2, 3.3],cons([1, 3],cons([1, 2], cons([0, 2], cons([0,1], cons([0,0], None))))))
    
test "Example find_nearby test":
    let e = example_from_handout()
    assert e.find_nearby(1,3,"bar", 1) == cons([1,3,"bar", "H Bar"], None)
    assert e.find_nearby(1,3,"bar", 2) == cons([1,3,"bar", "H Bar"],cons([1,3,"bar", "Bar None"] ,None))
    assert e.find_nearby(0,0, "region", 3) == None
    assert e.find_nearby(1,3,"bar", 3) == cons([1,3,"bar", "H Bar"],cons([1,3,"bar", "Bar None"] ,None))
    assert e.find_nearby(1,3,"bar", 0) == None
    assert e.find_nearby(0,2,"food", 3) == cons([0,1,"food", "Pasta"],cons([0,0,"food", "Sandwiches"] , cons([-0.2, 3.3, "food", "Burritos"],None)))
    
    
def my_own_example():
    return TripPlanner([[0,0,0,1],[0,0,1,0],[1,0,2,0],[0,2,0,3], [0,3,0,4]],[[0,0,"food", "A"], \
         [0,0, "bar", "B"], [0,1, "food", "C"], [0,1, "school", "D"], \
         [1,0,"bar", "F"], [1, 0, "food", "E"],[2,0, "school", "G"], [0,2, "food", "H"],[0,3, "school", "J"], [0,2, "bar", "I"]])
         
         
test "my_own_test":
    let e = my_own_example()
    assert e.find_route(0,0,"A") == cons([0,0],None)
    assert e.find_route(0,1,"J") == None
    assert e.find_route(0,4,"H") == cons([0, 4],cons([0, 3],cons([0, 2], None)))
    assert e.find_route(0,1,"G") == cons([0, 1],cons([0, 0],cons([1, 0], cons([2, 0],None))))
    assert e.find_route(1,0, "K") == None
    assert e.find_route(2,0, "D") == cons([2, 0],cons([1, 0],cons([0, 0], cons([0, 1],None))))
    
    assert e.find_nearby(0,0,"food", 3) == cons([0,0,"food", "A"],cons([1,0,"food", "E"] , cons([0, 1, "food", "C"],None)))
    assert e.find_nearby(0,0,"food", 4) == cons([0,0,"food", "A"],cons([1,0,"food", "E"] , cons([0, 1, "food", "C"],None)))
    assert e.find_nearby(0,4, "food", 2) == cons([0,2,"food", "H"] ,None)
    assert e.find_nearby(0,3,"Club", 1) == None
    assert e.find_nearby(2,0,"school", 3) == cons([2,0,"school", "G"],cons([0,1,"school", "D"],None))
    