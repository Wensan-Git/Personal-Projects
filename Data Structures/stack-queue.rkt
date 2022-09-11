#lang dssl2
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

# HW2: Stacks and Queues
#
# ** You must work on your own for this assignment. **

import ring_buffer

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

# Defined in the `ring_buffer` library; copied here for reference:
# interface QUEUE[T]:
#     def enqueue(self, element: T) -> NoneC
#     def dequeue(self) -> T
#     def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

###
### ListStack
###

class ListStack (STACK):

    # Any fields you may need can go here.
    let head
    # Constructs an empty ListStack.
    def __init__ (self):
        self.head = None
    #   ^ YOUR DEFINITION HERE
    

    # Other methods you may need can go here.
    def push(self, element):
        self.head = _cons(element, self.head)
        
    def pop(self):
        let top = self.head
        while not top == None:
            let top_data = top.data
            self.head = self.head.next
            return top.data
        error("the stack already ran out!")
       
    def empty?(self):
        if self.head == None:
            return True
        return False
        
test "woefully insufficient":
    let s = ListStack()
    s.push(2)
    assert s.pop() == 2
    assert s.empty?() == True
    assert_error s.pop()
    s.push(3)
    assert s.pop() == 3

test "ListStack":
    let l = ListStack()
    l.push(1)
    l.push(2)
    assert l.empty?() == False
    assert not l.empty?() == True
    assert l.pop() == 2
    assert l.empty?() == False
    assert l.pop() == 1
    assert l.empty?() == True
    assert_error l.pop()

###
### ListQueue
###
class ListQueue (QUEUE):

    # Any fields you may need can go here.
    let head
    let tail
    # Constructs an empty ListQueue.
    def __init__ (self):
        self.head = None
        self.tail = None
    #   ^ YOUR DEFINITION HERE

    def enqueue(self, element):
        if self.head == None:
            self.head = _cons(element, None)
            self.tail = _cons(element, None)
        elif self.head.next == None:
            self.head.next = _cons(element, None)
            self.tail = self.head.next
        else:
            self.tail.next = _cons(element, None)
            self.tail = self.tail.next
            
            
    def dequeue(self):
        if self.head == None:
            error("nothing to pop out")
        elif self.head == self.tail:
            let pop = self.head.data
            self.head = None
            self.tail = None
            return pop
        
        let pop = self.head.data 
        self.head = self.head.next
        return pop
        
    def empty?(self):
        return self.head == None


test "woefully insufficient, part 2":
    let q = ListQueue()
    q.enqueue(2)
    q.enqueue(2)
    assert q.dequeue() == 2
    assert q.dequeue() == 2
    assert_error q.dequeue()
    assert q.empty?() == True
    q.enqueue(4)
    q.enqueue(5)
    assert q.dequeue() == 4
    assert q.dequeue() == 5
    
    let l = ListQueue()
    q.enqueue(1)
    q.enqueue(2)
    q.enqueue(3)
    q.enqueue(4)
    assert q.dequeue() == 1
    assert q.dequeue() == 2
    assert q.dequeue() == 3
    assert q.dequeue() == 4
    assert q.empty?() == True
    assert_error q.dequeue()

###
### Playlists
###

struct song:
    let title: str?
    let artist: str?
    let album: str?

# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
    let song_1 = song("Holy Tears", "Isis", "In the Absence of Truth")
    let song_2 = song("Worth his Weight in Gold", "Steel Pulse", "True Democracy")
    let song_3 = song("Sheepdog", "Zaius","Of Adoration")
    let song_4 = song("Sailin’ On", "Bad Brains", "Rock for Light")
    let song_5 = song("She’s in Parties", "Bauhaus", "Burning from the Inside")
    q.enqueue(song_1)
    q.enqueue(song_2)
    q.enqueue(song_3)
    q.enqueue(song_4)
    q.enqueue(song_5)
    return q.dequeue()
    
#   ^ YOUR DEFINITION HERE

test "ListQueue playlist":
    assert fill_playlist(ListQueue()) == song("Holy Tears", "Isis", "In the Absence of Truth")

# To construct a RingBuffer: RingBuffer(capacity)
test "RingBuffer playlist":
    assert fill_playlist(RingBuffer(5)) == song("Holy Tears", "Isis", "In the Absence of Truth")
