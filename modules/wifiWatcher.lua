local audiodevice = require('hs.audiodevice')
local wifi = require('hs.wifi')
local timer = require('hs.timer')
local fnutils = require('hs.fnutils')
local env = require("env")
local plist = require("hs.plist")

local mod = {}

local doNotMuteNetworks = {
  "Biran",
  "Biran2",
  "BiranTLV",
  "condo"
  }

-- the default output device
local audioDevice = audiodevice.defaultOutputDevice()

wifiMonitor = wifi.watcher.new(function()
  timer.doAfter(2, function()
    local currentWifi = wifi.currentNetwork()
    if fnutils.contains(doNotMuteNetworks, currentWifi) then
      audioDevice:setOutputMuted(false)
    else
      if plist.read(env.settings).muteSoundWhenJoiningUnknownNetworks then
        audioDevice:setOutputMuted(true)
      end
    end
    end)
end)

function mod.init()
  wifiMonitor:start()
end

return mod
