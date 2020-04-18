local audiodevice = require("hs.audiodevice")
local wifi = require("hs.wifi")
local timer = require("hs.timer")
local fnutils = require("hs.fnutils")
local Settings = require("hs.settings")

local obj = {}

local settingKeys = settingKeys

obj.__index = obj
obj.name = "WifiWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local knownNetworks = {
  "Biran",
  "Biran2",
  "BiranTLV",
  "rbrt",
  "Shely_or",
  "Harelzabari"
}

obj.wifiWatcher = nil

local function wifiWatcherCallback()
  timer.doAfter(
    2,
    function()
      local muteSoundUnknownWifi = Settings.get(settingKeys.muteSoundForUnknownNetworks)
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

function obj:init()
  self.wifiWatcher = wifi.watcher.new(wifiWatcherCallback)
  wifiWatcherCallback()
  self.wifiWatcher:start()
end

return obj
