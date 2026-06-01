--!nocheck
local List = require("../src/SimpleList")
local PriorityQueue = require("../src/SimplePriorityQueue")
local Queue = require("../src/SimpleQueue")
local Stack = require("../src/SimpleStack")

local passed = 0
local function check(name: string, cond: boolean)
    if cond then
        passed += 1
    else
        error("FAIL: " .. name, 2)
    end
end

-- Stack
local s = Stack()
check("stack empty", s:IsEmpty() and s:Size() == 0)
s:Push(1)
s:Push(2)
s:Push(3)
check("stack size", s:Size() == 3)
check("stack peek", s:Peek() == 3)
check("stack peekAt", s:PeekAt(1) == 1)
check("stack has", s:Has(2) and not s:Has(99))
check("stack pop", s:Pop() == 3 and s:Pop() == 2 and s:Size() == 1)
do
    local order = {}
    s:Push(10)
    for i, v in s:Iterator() do
        table.insert(order, v)
    end
    check("stack iterator top-first", order[1] == 10 and order[2] == 1)
end
do
    -- Remove by value
    s:Clear()
    s:Push(1)
    s:Push(2)
    s:Push(3)
    check("stack remove missing", s:Remove(99) == false)
    check("stack remove value", s:Remove(2) == true and s:Size() == 2 and not s:Has(2))
    check("stack remove keeps order", s:PeekAt(1) == 1 and s:PeekAt(2) == 3)
end
s:Clear()
check("stack clear", s:IsEmpty())

-- Queue: stress the head/tail + compaction by interleaving enqueue/dequeue
local q = Queue()
for i = 1, 200 do
    q:Enqueue(i)
end
local expected = 1
for i = 1, 150 do
    check("queue fifo " .. i, q:Dequeue() == expected)
    expected += 1
end
check("queue size after partial drain", q:Size() == 50)
check("queue peek front", q:Peek() == expected)
check("queue peekAt 1", q:PeekAt(1) == expected)
check("queue peekAt last", q:PeekAt(50) == 200)
check("queue peekAt oob", q:PeekAt(51) == nil and q:PeekAt(0) == nil)
check("queue has live only", q:Has(200) and not q:Has(1))
-- Re-enqueue to confirm tail keeps growing correctly after compaction
for i = 201, 260 do
    q:Enqueue(i)
end
check("queue size after refill", q:Size() == 110)
do
    local first, count = nil, 0
    for _, v in q:Iterator() do
        if first == nil then
            first = v
        end
        count += 1
    end
    check("queue iterator front-first", first == expected)
    check("queue iterator count", count == 110)
end
-- Fully drain and ensure nil at the end + reset
while not q:IsEmpty() do
    q:Dequeue()
end
check("queue drained", q:Size() == 0 and q:Dequeue() == nil)
q:Enqueue(7)
check("queue reuse after drain", q:Dequeue() == 7)
do
    -- Remove by value preserves FIFO order of the remainder
    local rq = Queue()
    for i = 1, 5 do
        rq:Enqueue(i)
    end
    check("queue remove missing", rq:Remove(99) == false)
    check("queue remove mid", rq:Remove(3) == true and rq:Size() == 4)
    check("queue remove front", rq:Remove(1) == true and rq:Peek() == 2)
    local seq = {}
    while not rq:IsEmpty() do
        table.insert(seq, rq:Dequeue())
    end
    check("queue order after remove", table.concat(seq, ",") == "2,4,5")
end

-- List
local l = List()
l:Append(2)
l:Append(3)
l:Prepend(1)
l:Insert(2, 99)
check("list order", l:Get(1) == 1 and l:Get(2) == 99 and l:Get(3) == 2)
check("list first/last", l:GetFirst() == 1 and l:GetLast() == 3)
check("list find", l:Find(99) == 2 and l:Has(3) and l:Find(1234) == nil)
check("list removeFirst", l:RemoveFirst() == 1)
check("list removeLast", l:RemoveLast() == 3)
check("list removeAt idx", l:RemoveAt(1) == 99)
check("list remaining element", l:Size() == 1 and l:Get(1) == 2)
do
    -- Remove by value
    l:Clear()
    l:Append(10)
    l:Append(20)
    l:Append(30)
    check("list remove missing", l:Remove(99) == false)
    check("list remove value", l:Remove(20) == true and l:Size() == 2 and not l:Has(20))
    check("list remove keeps order", l:Get(1) == 10 and l:Get(2) == 30)
end
l:Clear()
check("list now empty", l:IsEmpty())

-- PriorityQueue (min-heap)
local pq = PriorityQueue(function(a, b)
    return a < b
end)
for _, v in { 5, 3, 8, 1, 9, 2, 7 } do
    pq:Enqueue(v)
end
check("pq peek min", pq:Peek() == 1)
local out = {}
while not pq:IsEmpty() do
    table.insert(out, pq:Dequeue())
end
check("pq sorted dequeue", table.concat(out, ",") == "1,2,3,5,7,8,9")
-- Iterator should yield priority order over a snapshot
local pq2 = PriorityQueue(function(a, b)
    return a > b
end) -- max-heap
for _, v in { 4, 1, 6, 2 } do
    pq2:Enqueue(v)
end
local it = {}
for _, v in pq2:Iterator() do
    table.insert(it, v)
end
check("pq max iterator order", table.concat(it, ",") == "6,4,2,1")
check("pq find predicate", pq2:Find(function(v)
    return v % 2 == 0
end) == 6)

-- Remove from the middle of the heap, then confirm ordering is intact.
local pq3 = PriorityQueue(function(a, b)
    return a < b
end)
for _, v in { 5, 3, 8, 1, 9, 2, 7, 4, 6 } do
    pq3:Enqueue(v)
end
check("pq remove missing", pq3:Remove(99) == false)
check("pq remove root", pq3:Remove(1) == true and pq3:Peek() == 2)
check("pq remove mid", pq3:Remove(5) == true and pq3:Size() == 7)
check("pq remove no longer has", not pq3:Has(5))
local rest = {}
while not pq3:IsEmpty() do
    table.insert(rest, pq3:Dequeue())
end
check("pq order after removals", table.concat(rest, ",") == "2,3,4,6,7,8,9")
-- Remove the last element specifically (index == #heap branch).
local pq4 = PriorityQueue(function(a, b)
    return a < b
end)
pq4:Enqueue(1)
pq4:Enqueue(2)
check("pq remove last element", pq4:Remove(2) == true and pq4:Size() == 1 and pq4:Peek() == 1)

-- capacity constructor smoke
local big = List(1000)
big:Append(1)
check("capacity ctor works", big:Size() == 1)

print(`All {passed} checks passed.`)
