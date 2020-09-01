local Hotkey = require("hs.hotkey")
local Eventtap = require("hs.eventtap")

local obj = {}

obj.__index = obj
obj.name = "BrightnessControl"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local brightnessControlModal = nil

local function systemKey(key)
  Eventtap.event.newSystemKeyEvent(string.upper(key), true):post()
  Eventtap.event.newSystemKeyEvent(string.upper(key), false):post()
end

local function increaseBrightness()
  systemKey("BRIGHTNESS_UP")
end

local function decreaseBrightness()
  systemKey("BRIGHTNESS_DOWN")
end

function obj.start()
  brightnessControlModal:enter()
end

function obj.stop()
  brightnessControlModal:exit()
end

function obj.init()
  -- obj.delayedTimer = Timer.delayed.new(1, obj.stop)
  brightnessControlModal = Hotkey.modal.new()
    :bind({}, "right", nil, increaseBrightness, increaseBrightness, nil)
    :bind({}, "left", nil, decreaseBrightness, decreaseBrightness, nil)
    :bind({}, "escape", nil, obj.stop, nil, nil)
    :bind({}, "return", nil, obj.stop, nil, nil)
end

return obj
