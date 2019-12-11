local chooser = require("util.FuzzyChooser")
local WiFi = require("hs.wifi")
local Dialog = require("hs.dialog")
local Image = require("hs.image")
local FNutils = require("hs.fnutils")

local obj = {}

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local locked = script_path() .. "/locked.pdf"
local unlocked = script_path() .. "/unlocked.pdf"

local function connect(network)
  if not network then
    return
  end
  local ssid = network.text
  if network.secure then
    local button, pass = Dialog.textPrompt(ssid, "Requires password", "", "OK", "Cancel")
    if button ~= "Cancel" then
      WiFi.associate(ssid, pass)
    end
  end
end

local function callback()
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
      table.insert(
        networks,
        {
          text = ssid,
          secure = secure,
          image = Image.imageFromPath(imagePath)
        }
      )
    end
    table.insert(seenSSIDs, ssid)
  end
  chooser.start(connect, networks, {"text"})
end

function obj:init()
end

function obj:start()
  WiFi.backgroundScan(callback)
end

return obj
