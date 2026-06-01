local SimpleList = require(script.SimpleList)
local SimplePriorityQueue = require(script.SimplePriorityQueue)
local SimpleQueue = require(script.SimpleQueue)
local SimpleStack = require(script.SimpleStack)

export type SimpleList<T> = SimpleList.List<T>
export type SimpleStack<T> = SimpleStack.Stack<T>
export type SimpleQueue<T> = SimpleQueue.Queue<T>
export type SimplePriorityQueue<T> = SimplePriorityQueue.PriorityQueue<T>

local suite = {}

suite.List  = SimpleList
suite.Queue = SimpleQueue
suite.Stack = SimpleStack
suite.PriorityQueue = SimplePriorityQueue

return suite