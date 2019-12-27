local Hotkey = require("hs.hotkey")
local Eventtap = require("hs.eventtap")
local Timer = require("hs.timer")

local obj = {}

obj.delayedTimer = nil
obj.brightnessControlModal = nil

local function systemKey(key)
  Eventtap.event.newSystemKeyEvent(string.upper(key), true)
    :post()
  Eventtap.event.newSystemKeyEvent(string.upper(key), false)
    :post()
  -- obj.delayedTimer:start()
end

local function increaseBrightness(repeating)
  systemKey("BRIGHTNESS_UP")
end

local function decreaseBrightness(repeating)
  systemKey("BRIGHTNESS_DOWN")
end

function obj:start()
  obj.brightnessControlModal:enter()
end

function obj:stop()
  obj.brightnessControlModal:exit()
end

function obj:init()
  -- obj.delayedTimer = Timer.delayed.new(1, obj.stop)
  obj.brightnessControlModal = Hotkey.modal.new()
    :bind({}, "right", nil, increaseBrightness, increaseBrightness, nil)
    :bind({}, "left", nil, decreaseBrightness, decreaseBrightness, nil)
    :bind({}, "escape", nil, obj.stop, nil, nil)
    :bind({}, "return", nil, obj.stop, nil, nil)
end

return obj
