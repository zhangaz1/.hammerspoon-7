local timer = require("hs.timer")

local obj = {}

-- https://github.com/Hammerspoon/Spoons/blob/master/Source/HoldToQuit.spoon/init.lua

obj.sentCallback = nil
obj.delayedTimer = nil

local function timerCallback()
  obj.sentCallback()
end

if not obj.delayedTimer then
  obj.delayedTimer = timer.delayed.new(0, timerCallback)
end

function obj.onHold(delay, callBackFn)
  spoon.InputWatcher:stop()
  obj.sentCallback = callBackFn
  obj.delayedTimer:setDelay(delay):start()
  spoon.InputWatcher:start()
end

function obj.onPress(func)
  spoon.InputWatcher:stop()
  if obj.delayedTimer and obj.delayedTimer:running() then
    obj.delayedTimer:stop()
    func()
  end
  spoon.InputWatcher:start()
end

return obj
