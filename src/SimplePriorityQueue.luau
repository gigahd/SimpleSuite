--!native
--!optimize 2
local insert = table.insert
local remove = table.remove
local sort = table.sort
local clone = table.clone
local tableFind = table.find
local tableClear = table.clear

export type PriorityQueue<T> = typeof(table.freeze({} :: {
    Size: () -> (number),
    IsEmpty: () -> (boolean),
    Clear: () -> (),
    Peek: () -> (T?),
    Dequeue: () -> (T?),
    Has: (element: T) -> (boolean),
    Find: (predicate: (value: T) -> boolean) -> (T?),
    Iterator: () -> (() -> (number?, T?)),
    Enqueue: (value: T) -> (),
}))

-- `comparator(a, b)` returns true when `a` should be dequeued before `b`.
-- It must be a strict ordering (use `<` / `>`, not `<=` / `>=`).
--   Min-heap: function(a, b) return a < b end
--   Max-heap: function(a, b) return a > b end
return function<T>(comparator: (a: T, b: T) -> boolean): PriorityQueue<T>
    local heap: { T } = {}

    local function siftUp(index: number)
        while index > 1 do
            local parentIndex = index // 2
            if not comparator(heap[index], heap[parentIndex]) then
                break
            end
            heap[index], heap[parentIndex] = heap[parentIndex], heap[index]
            index = parentIndex
        end
    end

    local function siftDown(index: number)
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

    local function size(): number
        return #heap
    end
    local function isEmpty(): boolean
        return #heap == 0
    end
    local function clear()
        tableClear(heap)
    end
    local function enqueue(value: T): ()
        insert(heap, value)
        siftUp(#heap)
    end
    local function peek(): T?
        return heap[1]
    end
    local function dequeue(): T?
        local length = #heap
        if length == 0 then
            return nil
        end

        local root = heap[1]
        if length == 1 then
            remove(heap)
        else
            heap[1] = heap[length]
            remove(heap)
            siftDown(1)
        end
        return root
    end
    local function has(element: T): boolean
        return tableFind(heap, element) ~= nil
    end
    -- Highest-priority element matching `predicate`. Single O(n) scan, no copy.
    local function find(predicate: (value: T) -> boolean): T?
        local best: T? = nil
        for _, value in heap do
            if predicate(value) and (best == nil or comparator(value, best)) then
                best = value
            end
        end
        return best
    end

    local function iterator(): () -> (number?, T?)
        local snapshot = clone(heap)
        sort(snapshot, comparator)
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

    return table.freeze({
        Size = size,
        IsEmpty = isEmpty,
        Clear = clear,
        Peek = peek,
        Dequeue = dequeue,
        Has = has,
        Find = find,
        Iterator = iterator,
        Enqueue = enqueue,
    })
end
