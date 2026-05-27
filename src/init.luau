local SimpleList = require(script.SimpleList)
local SimpleQueue = require(script.SimpleQueue)
local SimpleStack = require(script.SimpleStack)

export type SimpleList<T> = SimpleList.List<T>
export type SimpleStack<T> = SimpleStack.Stack<T>
export type SimpleQueue<T> = SimpleQueue.Queue<T>

local suite = {}

suite.List  = SimpleList
suite.Queue = SimpleQueue
suite.Stack = SimpleStack

return suite