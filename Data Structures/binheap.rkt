#lang dssl2


interface PRIORITY_QUEUE[X]:
    # Returns the number of elements in the priority queue.
    def len(self) -> nat?
    # Returns the smallest element; error if empty.
    def find_min(self) -> X
    # Removes the smallest element; error if empty.
    def remove_min(self) -> NoneC
    # Inserts an element; error if full.
    def insert(self, element: X) -> NoneC

    
# Class implementing the PRIORITY_QUEUE ADT as a binary heap.
class BinHeap[X] (PRIORITY_QUEUE):
    let _data: VecC[OrC(X, NoneC)]
    let _size: nat?
    let _lt?:  FunC[X, X, bool?]
    let _capacity

    # Constructs a new binary heap with the given capacity and
    # less-than function for type X.
    def __init__(self, capacity, lt?):
        self._data = [None; capacity]
        self._capacity = capacity
        self._lt? = lt?
        self._size = 0                     ### is using None correct? 

    def len(self):
        return self._size
        
    
    def find_smallest_child(self, index):
        let smallest = index
        if 2*index + 1 <= self._size - 1:
            if self._lt?(self._data[2*index + 1],self._data[smallest]):
                smallest = 2*index + 1
        if 2*index + 2 <= self._size -1:
            if self._lt?(self._data[2*index + 2],self._data[smallest]):
                smallest = 2*index + 2
        return smallest
                
    def swap(self, index1, index2):
        let data1 = self._data[index1]
        self._data[index1] = self._data[index2]
        self._data[index2] = data1
        
    def per_down(self, index):
        let small = self.find_smallest_child(index)
        if index == small:
            return
        else:
            self.swap(index, small)
            self.per_down(small)
    
    def bub_up(self, index):
        let large = self.find_larger_parent(index)
        if index == large:
            return
        else:
            self.swap(index, large)
            self.bub_up(large)
            
    def get_data(self):
        return self._data
            
    def find_larger_parent(self, index):
        let larger = index
        if (index-1)//2 >= 0:
            if self._lt?(self._data[index],self._data[(index-1)//2]):
                larger = (index-1)//2
        return larger

    def insert(self, new_element:X):
        if self._size == self._capacity:
            error("Sorry, there is no more room!")
        self._data[self._size] = new_element
        
        self._size = self._size + 1
        self.bub_up(self._size - 1)
        

    def find_min(self):
        if self._size == 0:
            error("there is no element!")
        return self._data[0]


    def remove_min(self):
        if self._size == 0:
            error("There is no more element to be removed!")
        self._data[0] = self._data[self._size - 1]
        self._data[self._size - 1] = None            ##### Don't forget to do a test on if this is indeed removed
        self._size = self._size - 1
        self.per_down(0)
        
        
            
            
            
 ##### "None" is not a marker that something does not exist; None 
        
#### ^^^ YOUR CODE HERE

# Woefully insufficient test.
test 'insert, insert, remove_min':
    # The `nat?` here means our elements are restricted to `nat?`s.
    let h = BinHeap[nat?](10, λ x, y: x < y)
    h.insert(1)
    h.insert(2)
    h.insert(0)
    h.insert(4)           #### When I inserted negative, it errored. Should I worry about this type of testing?
    h.insert(0)
    h.insert(3)
    assert_error h.insert(-1) 
    assert h.len()== 6
    assert h.find_min() == 0
    h.remove_min()
    assert h.len() == 5
    assert h.find_min() == 0
    h.remove_min()
    assert h.len() == 4
    assert h.find_min() == 1
    h.remove_min()
    h.remove_min()
    h.remove_min()
    assert h.len() == 1
    assert h.find_min()== 4
    h.remove_min()
    assert_error h.remove_min()
    assert_error h.find_min()

test 'continued test on BinHeap':
    let h = BinHeap(4, λ x, y: x > y)
    h.insert(-1)
    h.insert(None)
    h.insert(3)
    assert h.len() == 3
    h.insert(None)
    assert_error h.insert(4)
    assert h.find_min()== 3
    h.remove_min()
    assert h.len() == 3
    assert h.find_min() == None
    h.remove_min()
    assert h.find_min() == -1
    assert h.len() == 2
    h.remove_min()
    assert h.find_min() == None
    h.insert(2)
    assert h.find_min() == None
    h.remove_min()
    h.remove_min()
    assert_error h.remove_min()
    assert h.get_data() == [None; 4]

    
def test_string_by_length(s1, s2):
    return len(s1) < len(s2)
    
    
     
test "BinHeap word test":
    let h = BinHeap(4, λ x, y: test_string_by_length(x, y))
    assert h.len() == 0
    h.insert("apple")
    h.insert("apple")
    h.insert("get")
    h.insert("half")
    assert_error h.insert("anything")
    assert h.len() == 4
    assert h.find_min() == "get"
    h.remove_min()
    h.remove_min()
    assert h.find_min() == "apple"
    assert h.len() == 2
    h.remove_min()
    assert h.find_min() == "apple"
    h.remove_min()
    assert_error h.remove_min()
    assert h.len() == 0
    assert_error h.find_min()
     

# Sorts a vector of Xs, given a less-than function for Xs.
#
# This function performs a heap sort by inserting all of the
# elements of v into a fresh heap, then removing them in
# order and placing them back in v.
def heap_sort[X](v: VecC[X], lt?: FunC[X, X, bool?]) -> NoneC:
    let heap = BinHeap(len(v), lt?)
    for i in v:
       heap.insert(i)
    for i in range(heap.len()):
        v[i] = heap.find_min()
        heap.remove_min()
        
 

test 'heap sort descending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x > y)
    assert v == [6, 3, 2, 1, 0]

    
test 'another heapsort':
    let v = [1000, 12223, 132, 590, 285, None]
    heap_sort(v, λ x, y: x < y)
    assert v == [132, None, 285, 590, 1000, 12223]
    
test 'another heapsort1':
    let v = [None, None, None, None, None, None]
    heap_sort(v, λ x, y: x < y)
    assert v == [None, None, None, None, None, None]

test 'another heapsort2':
    let v = [None, None, None, None, 2, None]
    heap_sort(v, λ x, y: x < y)
    assert v == [None, None, 2, None, None, None]
 
test 'word heapsort':
    let v = ["tennis", "tenny", "brownie", "red"]
    heap_sort(v, λ x, y: x < y)
    assert v == ["brownie", "red", "tennis", "tenny"]


    
test 'word_length heapsort':
    let v = ["apple", "egg", "around", "ze"]
    heap_sort(v, λ x, y: test_string_by_length(x, y))
    assert v == ["ze", "egg", "apple", "around"]

# Sorting by birthday.

struct person:
    let name: str?
    let birth_month: nat?
    let birth_day: nat?
    
def compare_birthday(struct1, struct2):
    if struct1.birth_month == struct2.birth_month:
        return struct1.birth_day < struct2.birth_day
    else:
        return struct1.birth_month<struct2.birth_month
        
def earliest_birthday() -> str?:
    let person1 = person("Sylvie", 8, 7)
    let person2 = person("Gabrielle", 8, 25)
    let person3 = person("Hans", 9, 7)
    let person4 = person("Emily", 9, 7)
    let person5 = person("Wens", 2, 23)
    let person6 = person("Jeff", 2, 24)
    let person7 = person("Rain", 2, 23)
    let people = [person1,person2,person3,person4,person5, person6, person7]
    heap_sort(people, lambda x, y: compare_birthday(x,y))
    return people[0].name
    
    
test "earliest_birthday":
    assert earliest_birthday() == "Wens"
