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
  obj.sentCallback = callBackFn
  obj.delayedTimer:setDelay(delay):start()
end

function obj.onPress(func)
  if obj.delayedTimer and obj.delayedTimer:running() then
    obj.delayedTimer:stop()
    func()
  end
end

return obj
