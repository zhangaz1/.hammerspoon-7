local WiFi = require("hs.wifi")
local Dialog = require("hs.dialog")
local Image = require("hs.image")
local FNutils = require("hs.fnutils")
local Task = require("hs.task")
local GlobalChooser = require("util.GlobalChooser")

local obj = {}

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local locked = script_path() .. "/locked.pdf"
local unlocked = script_path() .. "/unlocked.pdf"

local function chooserCallback(network)
  if not network then
    return
  end
  local shouldConnect = true
  local ssid = network.text
  local password
  if network.secure then
    local button, pass = Dialog.textPrompt(ssid, "Requires password", "", "OK", "Cancel")
    if button ~= "Cancel" then
      password = pass
    else
      shouldConnect = false
    end
  else
    password = ""
  end
  if shouldConnect then
    Task.new("/usr/sbin/networksetup", nil, {"-setairportnetwork", "en0", ssid, password}):start()
  end
end

local function scanCallback()
  local currentWifi = WiFi.currentNetwork()
  local networks = {}
  local seenSSIDs = {}
  local interfaceDetails = WiFi.interfaceDetails()
  for _, v in ipairs(interfaceDetails.cachedScanResults) do
    local ssid = v.ssid
    local secure
    local imagePath
    if v.security[1] == "None" then
      imagePath = unlocked
      secure = false
    else
      imagePath = locked
      secure = true
    end
    if not FNutils.contains(seenSSIDs, v.ssid) then
      local item = {
        text = ssid,
        secure = secure,
        image = Image.imageFromPath(imagePath)
      }
      if ssid == currentWifi then
        item.subText = "Connected"
      end
      table.insert(networks, item)
    end
    table.insert(seenSSIDs, ssid)
  end
  GlobalChooser:start(chooserCallback, networks, {"text"})
end

function obj:start()
  WiFi.backgroundScan(scanCallback)
end

return obj
