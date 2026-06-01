--!native
--!optimize 2
local tableClear = table.clear
local tableCreate = table.create
local tableFind = table.find
local tableInsert = table.insert
local tableRemove = table.remove

-- Fields prefixed with `_` are internal; do not touch them directly.
export type Stack<T> = {
    _items: { T },

    Size: (self: Stack<T>) -> number,
    IsEmpty: (self: Stack<T>) -> boolean,
    Clear: (self: Stack<T>) -> (),
    PeekAt: (self: Stack<T>, index: number) -> T?,
    Peek: (self: Stack<T>) -> T?,
    Pop: (self: Stack<T>) -> T?,
    Remove: (self: Stack<T>, value: T) -> boolean,
    Has: (self: Stack<T>, value: T) -> boolean,
    Push: (self: Stack<T>, value: T) -> (),
    Iterator: (self: Stack<T>) -> () -> (number?, T?),
}

local Stack = {}
Stack.__index = Stack

function Stack.Size<T>(self: Stack<T>): number
    return #self._items
end

function Stack.IsEmpty<T>(self: Stack<T>): boolean
    return #self._items == 0
end

function Stack.Clear<T>(self: Stack<T>): ()
    tableClear(self._items)
end

function Stack.Push<T>(self: Stack<T>, value: T): ()
    tableInsert(self._items, value)
end

function Stack.PeekAt<T>(self: Stack<T>, index: number): T?
    return self._items[index]
end

function Stack.Peek<T>(self: Stack<T>): T?
    return self._items[#self._items]
end

function Stack.Pop<T>(self: Stack<T>): T?
    local items = self._items
    local height = #items
    local result = items[height]
    items[height] = nil
    return result
end

-- Removes the first occurrence of `value`. Returns whether anything was removed.
function Stack.Remove<T>(self: Stack<T>, value: T): boolean
    local index = tableFind(self._items, value)
    if index == nil then
        return false
    end
    tableRemove(self._items, index)
    return true
end

function Stack.Has<T>(self: Stack<T>, value: T): boolean
    return tableFind(self._items, value) ~= nil
end

-- Iterates from the top of the stack (last pushed) to the bottom.
function Stack.Iterator<T>(self: Stack<T>): () -> (number?, T?)
    local items = self._items
    local index = #items + 1
    return function(): (number?, T?)
        index -= 1
        if index < 1 then
            return nil, nil
        end
        return index, items[index]
    end
end

return function<T>(capacity: number?): Stack<T>
    local self: Stack<T> = setmetatable({
        _items = (if capacity then tableCreate(capacity) else {}) :: { T },
    }, Stack) :: any
    return self
end
