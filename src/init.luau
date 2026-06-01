local SimpleList = require(script.SimpleList)
local SimplePriorityQueue = require(script.SimplePriorityQueue)
local SimpleQueue = require(script.SimpleQueue)
local SimpleStack = require(script.SimpleStack)

export type List<T> = SimpleList.List<T>
export type Stack<T> = SimpleStack.Stack<T>
export type Queue<T> = SimpleQueue.Queue<T>
export type PriorityQueue<T> = SimplePriorityQueue.PriorityQueue<T>

local suite = {}

suite.List = SimpleList
suite.Queue = SimpleQueue
suite.Stack = SimpleStack
suite.PriorityQueue = SimplePriorityQueue

return suite
