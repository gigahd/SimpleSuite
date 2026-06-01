--!native
--!optimize 2
local insert = table.insert
local tableClear = table.clear

export type Queue<T> = typeof(table.freeze({} :: {
    Size: () -> (number),
    IsEmpty: () -> (boolean),
    Clear: () -> (),
    PeekAt: (index: number) -> (T?),
    Peek: () -> (T?),
    Dequeue: () -> (T?),
    Has: (element: T) -> (boolean),
    Enqueue: (value: T) -> (),
}))

return function<T>(): Queue<T>
    local queue: { T } = {}
    local function size(): number
        return #queue
    end
    local function isEmpty(): boolean
        return #queue == 0
    end
    local function clear()
        tableClear(queue)
    end
    local function enqueue(value: T): ()
        insert(queue, value)
    end
    local function peekAt(index: number): T?
        return queue[index]
    end
    local function dequeue(): T?
        return table.remove(queue, 1)
    end
    local function peek(): T?
        return queue[1]
    end
    local function has(element: T): boolean
        return table.find(queue, element) ~= nil
    end
    

    return table.freeze({
        Size = size,
        IsEmpty = isEmpty,
        Clear = clear,
        PeekAt = peekAt,
        Peek = peek,
        Dequeue = dequeue,
        Has = has,
        Enqueue = enqueue,
    })
end
