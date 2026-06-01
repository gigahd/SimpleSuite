# SimpleSuite

A Collection of simple Data Structures that I use in my games.

## Includes

- SimpleStack
- SimpleQueue (O(1) amortized enqueue/dequeue)
- SimpleList
- SimplePriorityQueue (binary heap)

Every structure shares a consistent surface: `Size`, `IsEmpty`, `Clear`, `Has`,
`Remove` (removes the first element equal to a value, returning a boolean), and
`Iterator`, plus its own operations. Each constructor takes an optional
`capacity` to pre-reserve the backing array. (On `List`, removal by index is
`RemoveAt`; `Remove` is by value, like the other structures.)

Get it on [Wally](https://wally.run/package/gigahd/simplesuite)

## Usage

> **Note:** As of `0.3.0` the structures are metatable-based and use
> **method (colon) call syntax**, e.g. `stack:Push(x)`. This is a breaking
> change from `0.2.x`, which used dot calls.

```lua
local SimpleSuite = require(path.to.SimpleSuite)

-- Stack (LIFO)
local stack = SimpleSuite.Stack()
stack:Push(1)
stack:Push(2)
print(stack:Pop()) --> 2

-- Queue (FIFO)
local queue = SimpleSuite.Queue()
queue:Enqueue("a")
queue:Enqueue("b")
print(queue:Dequeue()) --> a

-- List
local list = SimpleSuite.List()
list:Append(10)
list:Prepend(5)
print(list:Get(1)) --> 5

-- PriorityQueue (comparator: return true when `a` should leave before `b`)
local pq = SimpleSuite.PriorityQueue(function(a, b)
    return a < b -- min-heap
end)
pq:Enqueue(3)
pq:Enqueue(1)
print(pq:Dequeue()) --> 1

-- Iterate any structure
for index, value in stack:Iterator() do
    print(index, value)
end

-- Pre-reserve capacity for a known workload
local big = SimpleSuite.List(10_000)
```
