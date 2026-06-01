--!native
--!optimize 2
local tableClear = table.clear
local tableCreate = table.create
local tableFind = table.find
local tableInsert = table.insert
local tableRemove = table.remove

-- Fields prefixed with `_` are internal; do not touch them directly.
export type List<T> = {
    _items: { T },

    Size: (self: List<T>) -> number,
    IsEmpty: (self: List<T>) -> boolean,
    Clear: (self: List<T>) -> (),
    Get: (self: List<T>, index: number) -> T?,
    GetFirst: (self: List<T>) -> T?,
    GetLast: (self: List<T>) -> T?,
    RemoveAt: (self: List<T>, index: number) -> T?,
    RemoveFirst: (self: List<T>) -> T?,
    RemoveLast: (self: List<T>) -> T?,
    Remove: (self: List<T>, value: T) -> boolean,
    Has: (self: List<T>, value: T) -> boolean,
    Append: (self: List<T>, value: T) -> (),
    Prepend: (self: List<T>, value: T) -> (),
    Insert: (self: List<T>, index: number, value: T) -> (),
    Find: (self: List<T>, value: T) -> number?,
    Iterator: (self: List<T>) -> () -> (number?, T?),
}

local List = {}
List.__index = List

function List.Size<T>(self: List<T>): number
    return #self._items
end

function List.IsEmpty<T>(self: List<T>): boolean
    return #self._items == 0
end

function List.Clear<T>(self: List<T>): ()
    tableClear(self._items)
end

function List.Append<T>(self: List<T>, value: T): ()
    tableInsert(self._items, value)
end

function List.Prepend<T>(self: List<T>, value: T): ()
    tableInsert(self._items, 1, value)
end

function List.Insert<T>(self: List<T>, index: number, value: T): ()
    tableInsert(self._items, index, value)
end

function List.Get<T>(self: List<T>, index: number): T?
    return self._items[index]
end

function List.GetFirst<T>(self: List<T>): T?
    return self._items[1]
end

function List.GetLast<T>(self: List<T>): T?
    return self._items[#self._items]
end

function List.RemoveAt<T>(self: List<T>, index: number): T?
    return tableRemove(self._items, index)
end

function List.RemoveFirst<T>(self: List<T>): T?
    return tableRemove(self._items, 1)
end

function List.RemoveLast<T>(self: List<T>): T?
    local items = self._items
    local length = #items
    local result = items[length]
    items[length] = nil
    return result
end

function List.Find<T>(self: List<T>, value: T): number?
    return tableFind(self._items, value)
end

-- Removes the first occurrence of `value`. Returns whether anything was removed.
-- Use RemoveAt to remove by index.
function List.Remove<T>(self: List<T>, value: T): boolean
    local index = tableFind(self._items, value)
    if index == nil then
        return false
    end
    tableRemove(self._items, index)
    return true
end

function List.Has<T>(self: List<T>, value: T): boolean
    return tableFind(self._items, value) ~= nil
end

function List.Iterator<T>(self: List<T>): () -> (number?, T?)
    local items = self._items
    local count = #items
    local index = 0
    return function(): (number?, T?)
        index += 1
        if index > count then
            return nil, nil
        end
        return index, items[index]
    end
end

return function<T>(capacity: number?): List<T>
    local self: List<T> = setmetatable({
        _items = (if capacity then tableCreate(capacity) else {}) :: { T },
    }, List) :: any
    return self
end
