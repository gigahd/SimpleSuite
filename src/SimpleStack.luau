--!native
--!optimize 2
local insert = table.insert
local tableClear = table.clear
local tableFind = table.find

export type Stack<T> = typeof(table.freeze({} :: {
    Size: () -> (number),
    IsEmpty: () -> (boolean),
    Clear: () -> (),
    PeekAt: (index: number) -> (T?),
    Peek: () -> (T?),
    Pop: () -> (T?),
    Has: (element: T) -> (boolean),
    Push: (value: T) -> (),
}))

return function<T>(): Stack<T>
    local stack: { T } = {}
    local function size(): number
        return #stack
    end
    local function isEmpty(): boolean
        return #stack == 0
    end
    local function clear()
        tableClear(stack)
    end
    local function push(value: T): ()
        insert(stack, value)
    end
    local function peekAt(index: number): T?
        return stack[index]
    end
    local function pop(): T?
        local stackHeight = #stack
        local result = stack[stackHeight]
        stack[stackHeight] = nil
        return result
    end
    local function peek(): T?
        return stack[#stack]
    end
    local function has(element: T): boolean
        return tableFind(stack, element) ~= nil
    end
    

    return table.freeze({
        Size = size,
        IsEmpty = isEmpty,
        Clear = clear,
        PeekAt = peekAt,
        Peek = peek,
        Push = push,
        Has = has,
        Pop = pop
    })
end
