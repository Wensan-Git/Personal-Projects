#lang dssl2

# HW3: Dictionaries
#
# ** You must work on your own for this assignment. **


let eight_principles = ["Know your rights.", "Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

import sbox_hash

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)

    

# define struct for association list dictionary:
struct _cons:
    let key
    let value
    let next: OrC(_cons?, NoneC)
    
    
   
class AssociationList[K, V] (DICT):

    let _head
    #   ^ ADDITIONAL FIELDS HERE

    def __init__(self):
        self._head = None
    #   ^ YOUR DEFINITION HERE
        
        
    # helper:
    def find_x (self, x):
        let pin = self._head
        while not pin == None:
            if pin.key == x:
                return pin
            pin = pin.next
        return False

    def len(self) -> nat?:
        let length = 0
        let pin = self._head
        while not pin == None:
            length = length+ 1
            pin = pin.next
        return length

    def mem?(self, key: K) -> bool?:
        if self.find_x(key) == False:
            return False
        return True


    def get(self, key: K) -> V:
        if self.find_x(key) == False:
            error("key not in dictionary")
        return self.find_x(key).value

    def put(self, key: K, value: V) -> NoneC:
        let output = self.find_x(key)
        if output == False:
            self._head = _cons(key, value, self._head)
        else:
            output.value = value

    def del(self, key: K) -> NoneC:
        let pin = self._head
        if self._head == None:
            return
        if self._head.key == key:
            self._head = self._head.next
            return
        if pin.next == None:
            return
        while not pin.next == None:
            if pin.next.key == key:
                pin.next = pin.next.next
                return
            pin = pin.next
                
    #   ^ YOUR DEFINITION HERE

    # See above.
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5
    
    
test "association list":
    let a = AssociationList()
    a.del("good")
    assert a.len() == 0
    assert_error a.get("good")
    a.put("good", 1)
    a.put("bad", 1)
    assert a.len() == 2
    a.del("horrible")
    assert a.len() == 2
    a.put("special", 2)
    assert a.get("special") == 2
    a.put("special", 3)
    assert a.get("special") == 3
    a.len() == 3
    a.del("bad")
    assert a.len() == 2
    assert_error a.get("bad")
    assert a.mem?("good") == True
    assert a.mem?("bad") == False
    a.put("bad", 4)
    a.put("terrific", 6)
    a.put("handsome", 7)
    assert a.len() == 5
    assert a.mem?("handsome") == True
    assert a.get("terrific") == 6
    a.del("handsome")
    assert a.len() == 4
    assert_error a.get("handsome")
    a.del("good")
    assert a.len() == 3
    assert_error a.get("good")
    
    
    
test "associationlist 2":
    let h = AssociationList()
    assert h.len() == 0
    h.put("apple", 1)
    assert h.len() == 1
    assert h.mem?("apple")
    assert h.mem?("asparagus") == False

    h.put("astrok", 2)
    h.put("banana", 3)
    h.put("asparagus", 1)
    assert h.mem?("asparagus")
    assert h.len()== 4
    assert h.mem?("astrok")
    assert h.get("astrok") == 2
    assert h.get("asparagus") == 1
    assert h.get("banana") == 3
    h.del("banana")
    assert h.len() == 3
    assert h.mem?("banana") == False
    h.put("banana", 3)
    h.put("cucumber", 4)
    assert h.len() == 5
    h.del("astrok")
    assert h.mem?("astrok") == False
    assert h.len() == 4
    h.put("around", 10)
    h.put("about", 10)
    h.put("abbott", 10)
    assert h.get("abbott") == 10
    assert h.len() == 7
    assert h.mem?("about")
    assert h.get("apple") == 1
    h.del("abbott")
    assert h.mem?("abbott") == False
    assert h.len() == 6
    assert_error h.get("abbott")
    
    h.del("apple")
    assert_error h.get("apple")
    assert h.len() == 5
    assert h.mem?("apple") == False


    
    
    
    
class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data
    let _length

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._size = 0
        self._data = [None; nbuckets]
        self._length = nbuckets

    def len(self) -> nat?:
        return self._size
    
        
    def find_x (self,mapping, x):
        let pin = self._data[mapping]
        while not pin == None:
            if pin.key == x:
                return pin
            pin = pin.next
        return False
        
    def hash_x(self, x):
        return self._hash(x)%self._length

    def mem?(self, key: K) -> bool?:
        let mapping = self.hash_x(key)
        if self.find_x(mapping, key) == False:
            return False
        return True
        
        
    def get(self, key: K) -> V:
        let mapping = self.hash_x(key)
        if self._data[mapping] == None:
            error("not even such hash code!!!")
        let result = self.find_x(mapping, key)
        if result == False:
            error("no such a key!")
        return result.value

    def put(self, key: K, value: V) -> NoneC:
        let mapping = self.hash_x(key)
        let result = self.find_x(mapping, key)
        if result == False:
            self._data[mapping] = _cons(key, value, self._data[mapping])
            self._size = self._size + 1
        else:
            result.value = value
            

    def del(self, key: K) -> NoneC:
        
        let mapping = self.hash_x(key)
        let pin = self._data[mapping]
        if pin == None:
            return
        if self._data[mapping].key == key:
            self._data[mapping] = self._data[mapping].next
            self._size = self._size- 1
            return
        if pin.next == None:
            return
        while not pin.next == None:
            if pin.next.key == key:
                pin.next = pin.next.next
                self._size =self._size - 1
                return
            pin = pin.next
      
        
        

    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)


# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5
    h.put("aloha", 6)
    h.put("Nihao", 7)
    h.put("helo", 5)
    h.put("pello", 8)
    h.put("Bonjour", 9)
    assert h.len() == 6
    assert h.mem?("pello")
    assert h.mem?("Hola") == False
    assert h.get("Bonjour") == 9
    assert h.get("Nihao") == 7
    h.del("aloha")
    h.del("Nihao")
    assert_error h.get("Nihao")
    assert h.mem?("aloha") == False
    assert h.len() == 4
    
test "different_hash_function":
    let h = HashTable(15, make_sbox_hash())
    assert not h.mem?('ello')
    h.put('ello', 4)
    assert h.len() == 1
    assert h.mem?('ello')
    assert h.get('ello') == 4
    h.put("aloha", 6)
    h.put("Nihao", 7)
    h.put("helo", 5)
    h.put("pello", 8)
    h.put("Bonjour", 9)
    assert h.len() == 6
    assert h.mem?("pello")
    assert h.mem?("Hola") == False
    assert h.get("Bonjour") == 9
    assert h.get("Nihao") == 7
    h.del("aloha")
    h.del("Nihao")
    assert_error h.get("Nihao")
    assert h.mem?("aloha") == False
    assert h.len() == 4
    
    
        
test "hashtable":
    let h = HashTable(20, first_char_hasher)
    assert h.len() == 0
    h.put("apple", 1)
    assert h.len() == 1
    assert h.mem?("apple")
    assert h.mem?("asparagus") == False

    h.put("astrok", 2)
    h.put("banana", 3)
    h.put("asparagus", 1)
    assert h.mem?("asparagus")
    assert h.len()== 4
    assert h.mem?("astrok")
    assert h.get("astrok") == 2
    assert h.get("asparagus") == 1
    assert h.get("banana") == 3
    h.del("banana")
    assert h.len() == 3
    assert h.mem?("banana") == False
    h.put("banana", 3)
    h.put("cucumber", 4)
    assert h.len() == 5
    h.del("astrok")
    assert h.mem?("astrok") == False
    assert h.len() == 4
    h.put("around", 10)
    h.put("about", 10)
    h.put("abbott", 10)
    assert h.get("abbott") == 10
    assert h.len() == 7
    assert h.mem?("about")
    assert h.get("apple") == 1
    h.del("abbott")
    assert h.mem?("abbott") == False
    assert h.len() == 6
    assert_error h.get("abbott")
    
    h.del("apple")
    assert_error h.get("apple")
    assert h.len() == 5
    assert h.mem?("apple") == False
        



struct food:
    let dish: str?
    let cuisine: str?

def compose_menu(d: DICT!) -> DICT?:
    let food1 = food("Sushi", "Japanese")
    let food2 = food("Masala dosa", "Indian")
    let food3 = food("Apple pie", "American")
    let food4 = food("Spaghetti", "Italian")
    let food5 = food("Channa masala", "Indian")
    d.put("Jesse", food1)
    d.put("Stevie", food2)
    d.put("Branden", food3)
    d.put("Carol", food4)
    d.put("Sara", food5)
    return d

test "AssociationList menu":
    let d = AssociationList()
    assert d.len() == 0
    d.put("Wensa", food("Kongpao Chicken", "Chinese"))
    assert d.mem?("Wensa")
    assert d.len() == 1
    assert d.get("Wensa") ==  food("Kongpao Chicken", "Chinese")
    assert_error d.get("Vinsa")
    compose_menu(d)
    assert d.len() == 6
    assert d.get("Carol") == food("Spaghetti", "Italian")
    assert d.get("Carol").cuisine == "Italian"
    assert_error d.get("Caroll")
    assert d.mem?("Branden")
    d.del("Stevie")
    assert d.len() == 5
    assert_error d.get("Stevie")
    assert d.mem?("Stevie") == False
        
    
    
test "HashTable menu":
    let d = HashTable(15, make_sbox_hash())
    assert d.len() == 0
    d.put("Wens", food("Kongpao Chicken", "Chinese"))
    assert d.mem?("Wens")
    assert d.len() == 1
    assert d.get("Wens") ==  food("Kongpao Chicken", "Chinese")
    assert_error d.get("Vinsa")
    compose_menu(d)
    assert d.len() == 6
    assert d.get("Carol") == food("Spaghetti", "Italian")
    assert d.get("Carol").cuisine == "Italian"
    assert d.get("Stevie").cuisine == "Indian"
    assert_error d.get("Caroll")
    assert d.mem?("Branden")
    d.del("Stevie")
    assert d.len() == 5
    assert_error d.get("Stevie")
    assert d.mem?("Stevie") == False
    
test "HashTable menu2":
    let h = HashTable(20, make_sbox_hash())
    assert h.len() == 0
    h.put("Wensa", food("Kongpao Chicken", "Chinese"))
    assert h.mem?("Wensa")
    assert h.len() == 1
    assert h.get("Wensa") ==  food("Kongpao Chicken", "Chinese")
    assert_error h.get("Vinsa")
    compose_menu(h)
    assert h.len() == 6
    assert h.get("Carol") == food("Spaghetti", "Italian")
    assert h.get("Carol").cuisine == "Italian"
    assert h.get("Stevie").cuisine == "Indian"
    assert_error h.get("Caroll")
    assert h.mem?("Branden")
    h.del("Stevie")
    assert h.len() == 5
    assert_error h.get("Stevie")
    assert h.mem?("Stevie") == False
    
    


    
    
    
    
    
    
    
    
    
    
    
    
###
### DFS
###

# dfs : WU_GRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WU_GRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    let seen = [False; graph.len()]
    
### ^ YOUR CODE HERE

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
