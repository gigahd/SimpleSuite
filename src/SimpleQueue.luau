--!native
--!optimize 2
local tableClear = table.clear
local tableCreate = table.create

-- Compact the backing array only once the dead prefix is both sizeable and
-- larger than the live region, keeping Dequeue O(1) amortized.
local COMPACT_THRESHOLD = 64

-- Fields prefixed with `_` are internal; do not touch them directly.
-- The backing array is never shifted on Dequeue; `_head`/`_tail` track the
-- live window, so both Enqueue and Dequeue are O(1) amortized.
export type Queue<T> = {
    _items: { T },
    _head: number,
    _tail: number,

    Size: (self: Queue<T>) -> number,
    IsEmpty: (self: Queue<T>) -> boolean,
    Clear: (self: Queue<T>) -> (),
    PeekAt: (self: Queue<T>, index: number) -> T?,
    Peek: (self: Queue<T>) -> T?,
    Dequeue: (self: Queue<T>) -> T?,
    Remove: (self: Queue<T>, value: T) -> boolean,
    Has: (self: Queue<T>, value: T) -> boolean,
    Enqueue: (self: Queue<T>, value: T) -> (),
    Iterator: (self: Queue<T>) -> () -> (number?, T?),
}

local Queue = {}
Queue.__index = Queue

function Queue.Size<T>(self: Queue<T>): number
    return self._tail - self._head + 1
end

function Queue.IsEmpty<T>(self: Queue<T>): boolean
    return self._head > self._tail
end

function Queue.Clear<T>(self: Queue<T>): ()
    tableClear(self._items)
    self._head = 1
    self._tail = 0
end

function Queue.Enqueue<T>(self: Queue<T>, value: T): ()
    local tail = self._tail + 1
    self._tail = tail
    self._items[tail] = value
end

function Queue.Dequeue<T>(self: Queue<T>): T?
    local head = self._head
    local tail = self._tail
    if head > tail then
        return nil
    end

    local items = self._items
    local value = items[head]
    items[head] = nil
    head += 1

    if head > tail then
        -- Drained: reset so the array stays compact for future use.
        self._head = 1
        self._tail = 0
    elseif head > COMPACT_THRESHOLD and head * 2 > tail then
        -- Dead prefix dominates: slide the live region back to index 1.
        local count = 0
        for i = head, tail do
            count += 1
            items[count] = items[i]
        end
        for i = count + 1, tail do
            items[i] = nil
        end
        self._head = 1
        self._tail = count
    else
        self._head = head
    end

    return value
end

function Queue.Peek<T>(self: Queue<T>): T?
    return self._items[self._head]
end

-- 1-based from the front of the queue.
function Queue.PeekAt<T>(self: Queue<T>, index: number): T?
    if index < 1 then
        return nil
    end
    local position = self._head + index - 1
    if position > self._tail then
        return nil
    end
    return self._items[position]
end

-- Removes the first occurrence of `value`, preserving FIFO order of the rest.
-- Returns whether anything was removed.
function Queue.Remove<T>(self: Queue<T>, value: T): boolean
    local items = self._items
    local tail = self._tail
    for i = self._head, tail do
        if items[i] == value then
            for j = i, tail - 1 do
                items[j] = items[j + 1]
            end
            items[tail] = nil
            self._tail = tail - 1
            return true
        end
    end
    return false
end

function Queue.Has<T>(self: Queue<T>, value: T): boolean
    local items = self._items
    for i = self._head, self._tail do
        if items[i] == value then
            return true
        end
    end
    return false
end

-- Iterates from the front of the queue (next to be dequeued) to the back.
function Queue.Iterator<T>(self: Queue<T>): () -> (number?, T?)
    local items = self._items
    local tail = self._tail
    local i = self._head - 1
    local position = 0
    return function(): (number?, T?)
        i += 1
        if i > tail then
            return nil, nil
        end
        position += 1
        return position, items[i]
    end
end

return function<T>(capacity: number?): Queue<T>
    local self: Queue<T> = setmetatable({
        _items = (if capacity then tableCreate(capacity) else {}) :: { T },
        _head = 1,
        _tail = 0,
    }, Queue) :: any
    return self
end
