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

local doNotMuteNetworks = {
  "Biran",
  "Biran2",
  "BiranTLV",
  "rbrt"
}

local function watcherCallback()
  timer.doAfter(
    2,
    function()
      local audioDevice = audiodevice.defaultOutputDevice()
      local currentWifi = wifi.currentNetwork()
      if fnutils.contains(doNotMuteNetworks, currentWifi) then
        audioDevice:setOutputMuted(false)
      else
        local vacationModeKey = "muteSoundWhenJoiningUnknownNetworks"
        local vacationMode = Settings.get(vacationModeKey)
        if vacationMode == nil then
          Settings.set(vacationModeKey, true)
          vacationMode = false
        end
        if not vacationMode then
          audioDevice:setOutputMuted(true)
        else
          print("VACATION MODE ON")
        end
      end
    end
  )
end

obj.wifiWatcher = nil

function obj:start()
  watcherCallback()
  self.wifiWatcher:start()
end

function obj:init()
  self.wifiWatcher = wifi.watcher.new(watcherCallback)
end

return obj
