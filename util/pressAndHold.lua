local timer = require("hs.timer")
local eventtap = require("hs.eventtap")

local m = {}

-- http://phrogz.net/lua/LearningLua_Scope.html
-- https://github.com/Hammerspoon/Spoons/blob/master/Source/HoldToQuit.spoon/init.lua

m.delayedTimer = nil

m.onKeyDown = function(delay, callBackFn)
    m.delayedTimer = timer.delayed.new(delay, callBackFn)
    m.delayedTimer:start()
end

m.onKeyUp = function(modal, keys)
  if m.delayedTimer:running() then
    m.delayedTimer:stop()
    modal:exit()
    eventtap.keyStroke(table.unpack(keys))
    modal:enter()
  end
end

return m
