--!native
--!optimize 2
local tableClear = table.clear
local tableClone = table.clone
local tableCreate = table.create
local tableFind = table.find
local tableInsert = table.insert
local tableRemove = table.remove
local tableSort = table.sort

-- Fields prefixed with `_` are internal; do not touch them directly.
export type PriorityQueue<T> = {
    _heap: { T },
    _comparator: (a: T, b: T) -> boolean,

    Size: (self: PriorityQueue<T>) -> number,
    IsEmpty: (self: PriorityQueue<T>) -> boolean,
    Clear: (self: PriorityQueue<T>) -> (),
    Peek: (self: PriorityQueue<T>) -> T?,
    Dequeue: (self: PriorityQueue<T>) -> T?,
    Remove: (self: PriorityQueue<T>, value: T) -> boolean,
    Has: (self: PriorityQueue<T>, value: T) -> boolean,
    Find: (self: PriorityQueue<T>, predicate: (value: T) -> boolean) -> T?,
    Iterator: (self: PriorityQueue<T>) -> () -> (number?, T?),
    Enqueue: (self: PriorityQueue<T>, value: T) -> (),
}

local function siftUp<T>(heap: { T }, comparator: (a: T, b: T) -> boolean, index: number)
    while index > 1 do
        local parentIndex = index // 2
        if not comparator(heap[index], heap[parentIndex]) then
            break
        end
        heap[index], heap[parentIndex] = heap[parentIndex], heap[index]
        index = parentIndex
    end
end

local function siftDown<T>(heap: { T }, comparator: (a: T, b: T) -> boolean, index: number)
    local length = #heap
    while true do
        local leftIndex = index * 2
        local rightIndex = leftIndex + 1
        local highest = index

        if leftIndex <= length and comparator(heap[leftIndex], heap[highest]) then
            highest = leftIndex
        end
        if rightIndex <= length and comparator(heap[rightIndex], heap[highest]) then
            highest = rightIndex
        end
        if highest == index then
            break
        end

        heap[index], heap[highest] = heap[highest], heap[index]
        index = highest
    end
end

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue.Size<T>(self: PriorityQueue<T>): number
    return #self._heap
end

function PriorityQueue.IsEmpty<T>(self: PriorityQueue<T>): boolean
    return #self._heap == 0
end

function PriorityQueue.Clear<T>(self: PriorityQueue<T>): ()
    tableClear(self._heap)
end

function PriorityQueue.Enqueue<T>(self: PriorityQueue<T>, value: T): ()
    local heap = self._heap
    tableInsert(heap, value)
    siftUp(heap, self._comparator, #heap)
end

function PriorityQueue.Peek<T>(self: PriorityQueue<T>): T?
    return self._heap[1]
end

function PriorityQueue.Dequeue<T>(self: PriorityQueue<T>): T?
    local heap = self._heap
    local length = #heap
    if length == 0 then
        return nil
    end

    local root = heap[1]
    if length == 1 then
        tableRemove(heap)
    else
        heap[1] = heap[length]
        tableRemove(heap)
        siftDown(heap, self._comparator, 1)
    end
    return root
end

-- Removes the first occurrence of `value`, restoring the heap invariant.
-- O(n) to locate, O(log n) to re-heapify. Returns whether anything was removed.
function PriorityQueue.Remove<T>(self: PriorityQueue<T>, value: T): boolean
    local heap = self._heap
    local index = tableFind(heap, value)
    if index == nil then
        return false
    end

    local last = #heap
    if index == last then
        tableRemove(heap)
    else
        -- Backfill the gap with the last element, then re-settle it. Only one
        -- of the two sifts can move it, so running both is safe and correct.
        heap[index] = heap[last]
        tableRemove(heap)
        local comparator = self._comparator
        siftDown(heap, comparator, index)
        siftUp(heap, comparator, index)
    end
    return true
end

function PriorityQueue.Has<T>(self: PriorityQueue<T>, value: T): boolean
    return tableFind(self._heap, value) ~= nil
end

-- Highest-priority element matching `predicate`. Single O(n) scan, no copy.
function PriorityQueue.Find<T>(self: PriorityQueue<T>, predicate: (value: T) -> boolean): T?
    local comparator = self._comparator
    local best: T? = nil
    for _, value in self._heap do
        if predicate(value) and (best == nil or comparator(value, best)) then
            best = value
        end
    end
    return best
end

-- Yields elements in priority order over a sorted snapshot; mutating the queue
-- mid-iteration does not affect the in-progress traversal.
function PriorityQueue.Iterator<T>(self: PriorityQueue<T>): () -> (number?, T?)
    local snapshot = tableClone(self._heap)
    tableSort(snapshot, self._comparator)
    local count = #snapshot
    local index = 0
    return function(): (number?, T?)
        index += 1
        if index > count then
            return nil, nil
        end
        return index, snapshot[index]
    end
end

-- `comparator(a, b)` returns true when `a` should be dequeued before `b`.
-- It must be a strict ordering (use `<` / `>`, not `<=` / `>=`).
--   Min-heap: function(a, b) return a < b end
--   Max-heap: function(a, b) return a > b end
return function<T>(comparator: (a: T, b: T) -> boolean, capacity: number?): PriorityQueue<T>
    local self: PriorityQueue<T> = setmetatable({
        _heap = (if capacity then tableCreate(capacity) else {}) :: { T },
        _comparator = comparator,
    }, PriorityQueue) :: any
    return self
end
