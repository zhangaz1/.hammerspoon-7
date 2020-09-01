local audiodevice = require("hs.audiodevice")
local wifi = require("hs.wifi")
local timer = require("hs.timer")
local fnutils = require("hs.fnutils")
local Settings = require("hs.settings")

local obj = {}

obj.__index = obj
obj.name = "WifiWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local settingKey = "RBMuteSoundWhenJoiningUnknownNetworks"
local knownNetworks = {
  "Biran",
  "Biran2",
  "BiranTLV",
  "rbrt",
  "Shely_or",
  "Harelzabari"
}
local isActive = false
local wifiWatcher = nil

local function wifiWatcherCallback()
  timer.doAfter(
    2,
    function()
      local muteSoundUnknownWifi = Settings.get(settingKey)
      local audioDevice = audiodevice.defaultOutputDevice()
      local currentWifi = wifi.currentNetwork()
      if fnutils.contains(knownNetworks, currentWifi) or muteSoundUnknownWifi == false then
        audioDevice:setOutputMuted(false)
      else
        audioDevice:setOutputMuted(true)
      end
    end
  )
end

function obj:start()
  wifiWatcherCallback()
  wifiWatcher:start()
  isActive = true
end

function obj:stop()
  wifiWatcher:stop()
  isActive = false
end

function obj:isActive()
  return isActive
end

function obj:toggle()
  if isActive then
    wifiWatcher:stop()
  else
    wifiWatcher:start()
  end
end

function obj:init()
  Settings.set(settingKey, true)
  wifiWatcher = wifi.watcher.new(wifiWatcherCallback)
end

return obj
