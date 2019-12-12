local audiodevice = require("hs.audiodevice")
local wifi = require("hs.wifi")
local timer = require("hs.timer")
local fnutils = require("hs.fnutils")
local env = require("env")
local plist = require("hs.plist")

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

obj.wifiWatcher = nil

function obj:init()
  self.wifiWatcher =
    wifi.watcher.new(
    function()
      timer.doAfter(
        2,
        function()
          local audioDevice = audiodevice.defaultOutputDevice()
          local currentWifi = wifi.currentNetwork()
          if fnutils.contains(doNotMuteNetworks, currentWifi) then
            audioDevice:setOutputMuted(false)
          else
            if plist.read(env.settings).muteSoundWhenJoiningUnknownNetworks then
              audioDevice:setOutputMuted(true)
            end
          end
        end
      )
    end
  ):start()
end

return obj
