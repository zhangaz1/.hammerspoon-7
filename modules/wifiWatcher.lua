local audiodevice = require('hs.audiodevice')
local wifi = require('hs.wifi')
local timer = require('hs.timer')
local fnutils = require('hs.fnutils')

local mod = {}

local doNotMuteNetworks = {
  "Biran",
  "Biran2",
  "BiranTLV",
  "condo"
  }

-- the default output device
local audioDevice = audiodevice.defaultOutputDevice()
local wifiMonitor = wifi.watcher.new(function()
  timer.doAfter(2, function()
    local currentWifi = wifi.currentNetwork()
    if fnutils.contains(doNotMuteNetworks, currentWifi) then
      audioDevice:setOutputMuted(false)
    else
      audioDevice:setOutputMuted(true)
    end
    end)
end)

function mod.init()
  wifiMonitor:start()
end

return mod
