local SimpleList = require(script.SimpleList)
local SimpleQueue = require(script.SimpleQueue)
local SimpleStack = require(script.SimpleStack)

local suite = {}

suite.List  = SimpleList
suite.Queue = SimpleQueue
suite.Stack = SimpleStack

return suite