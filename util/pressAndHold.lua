local timer = require("hs.timer")
local eventtap = require("hs.eventtap")

local obj = {}

-- https://github.com/Hammerspoon/Spoons/blob/master/Source/HoldToQuit.spoon/init.lua

obj.sentCallback = nil
obj.delayedTimer = nil

local function timerCallback() obj.sentCallback() end

if not obj.delayedTimer then obj.delayedTimer = timer.delayed.new(0, timerCallback) end

obj.onKeyDown = function(delay, callBackFn)
  obj.sentCallback = callBackFn
  obj.delayedTimer:setDelay(delay):start()
end

obj.onKeyUp = function(modal, keys)
  if obj.delayedTimer and obj.delayedTimer:running() then
    obj.delayedTimer:stop()
    modal:exit()
    eventtap.keyStroke(table.unpack(keys))
    modal:enter()
  end
end

return obj
