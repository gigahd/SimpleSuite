--!native
--!optimize 2
local tableInsert = table.insert
local tableClear = table.clear
local tableFind = table.find
local tableRemove = table.remove

export type List<T> = typeof(table.freeze({} :: {
    Size: () -> number,
    IsEmpty: () -> boolean,
    Clear: () -> (),
    Get: (index: number) -> T?,
    GetFirst: () -> T?,
    GetLast: () -> T?,
    Remove: (index: number) -> T?,
    RemoveFirst: () -> T?,
    RemoveLast: () -> T?,
    Has: (element: T) -> boolean,
    Append: (value: T) -> (),
    Prepend: (value: T) -> (),
    Insert: (index: number, value: T) -> (),
    Find: (value: T) -> number?,
}))

return function<T>(initialLength: number?, initialValue: T?): List<T>
    local list: { T } = if initialLength then table.create(initialLength, initialValue) else {}
    local function size(): number
        return #list
    end
    local function isEmpty(): boolean
        return #list == 0
    end
    local function clear()
        tableClear(list)
    end
    local function prepend(value: T)
        tableInsert(list, 1, value)
    end
    local function insert(index: number, value: T)
        tableInsert(list, index, value)
    end
    local function append(value: T): ()
        tableInsert(list, value)
    end
    local function getFirst(): T?
        return list[1]
    end
    local function get(index: number): T?
        return list[index]
    end
    local function getLast(): T?
        return list[#list]
    end
    local function remove(index: number): T?
        return tableRemove(list, index)
    end
    local function removeLast(): T?
        local stackHeight = #list
        local result = list[stackHeight]
        list[stackHeight] = nil
        return result
    end
    local function removeFirst(): T?
        return tableRemove(list, 1)
    end
    local function find(value: T): number?
        return tableFind(list, value)
    end
    local function has(value: T): boolean
        return tableFind(list, value) ~= nil
    end

    return table.freeze({
        Size = size,
        IsEmpty = isEmpty,
        Clear = clear,
        Get = get,
        GetFirst = getFirst,
        GetLast = getLast,
        Has = has,
        Remove = remove,
        RemoveLast = removeLast,
        RemoveFirst = removeFirst,
        Prepend = prepend,
        Append = append,
        Insert = insert,
        Find = find,
    })
end
