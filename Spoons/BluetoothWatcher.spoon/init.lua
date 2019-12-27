local Menubar = require("hs.menubar")
local PathWatcher = require("hs.pathwatcher")
local Battery = require("hs.battery")
local Timer = require("hs.timer")
local util = require("rb.util")

local obj = {}

obj.__index = obj
obj.name = "BluetoothWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()
obj.delayedTimer = nil
obj.pathwatcher = nil
obj.airPodsMenuBarItem = nil
obj.magicMouseMenuBarItem = nil

local airPodsMacAddress = util.cloudSettings.get("airPodsMacAddress")

local icons = {
  bothBlack = obj.spoonPath .. "/bothBlack.pdf",
  rightBlack = obj.spoonPath .. "/rightBlack.pdf",
  leftBlack = obj.spoonPath .. "/leftBlack.pdf",
  magicMouseBlack = obj.spoonPath .. "/MagicMouseBlack.pdf",
  magicMouseRed = obj.spoonPath .. "/MagicMouseRed.pdf"
}

local function getStatus()
  local airPodsFound = false
  for _, device in ipairs(Battery.privateBluetoothBatteryInfo()) do
    if device.address == airPodsMacAddress then
      -- primary - the first airpod inserted?
      local primaryInEar = (device.primaryInEar == "YES")
      local secondaryInEar = (device.secondaryInEar == "YES")
      local batteryPercentRight = device.batteryPercentRight
      local batteryPercentLeft = device.batteryPercentLeft

      local primaryBud = device.primaryBud
      local secondaryBud
      if primaryBud == "leftBlack" then
        secondaryBud = "rightBlack"
      else
        secondaryBud = "leftBlack"
      end

      local primaryIcon = icons[primaryBud]
      local secondaryIcon = icons[secondaryBud]

      if primaryInEar and secondaryInEar then
        obj.airPodsMenuBarItem:returnToMenuBar():setIcon(icons.bothBlack)
      elseif primaryInEar then
        obj.airPodsMenuBarItem:returnToMenuBar():setIcon(primaryIcon)
      elseif secondaryInEar then
        obj.airPodsMenuBarItem:returnToMenuBar():setIcon(secondaryIcon)
      else
        obj.airPodsMenuBarItem:removeFromMenuBar()
      end
      airPodsFound = true
      break
    end
  end
  if not airPodsFound then
    obj.airPodsMenuBarItem:removeFromMenuBar()
  end

  for _, device in ipairs(Battery.otherBatteryInfo()) do
    if string.find(device.Product, "Magic Mouse") then
      if device.BatteryPercent > 20 then
        obj.magicMouseMenuBarItem:setIcon(icons.magicMouseBlack)
      else
        obj.magicMouseMenuBarItem:setIcon(icons.magicMouseRed, false)
      end
      return obj.magicMouseMenuBarItem:returnToMenuBar()
    end
  end
  obj.magicMouseMenuBarItem:removeFromMenuBar()
end

local function delayedTimerCallback()
  getStatus()
end

function obj:init()
  self.airPodsMenuBarItem = Menubar.new()
  self.magicMouseMenuBarItem = Menubar.new()
  self.delayedTimer = Timer.delayed.new(0.5, delayedTimerCallback)
  self.pathwatcher =
    PathWatcher.new(
    "/Library/Preferences/com.apple.Bluetooth.plist",
    function()
      self.delayedTimer:start()
    end
  ):start()
  getStatus()
end

return obj
