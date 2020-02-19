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

local airPodsMacAddress = util.cloudSettings.get("airPodsMacAddress")

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()

obj.delayedTimer = nil
obj.pathWatcher = nil
obj.magicMouseMenuBarItem = nil
obj.RightAirPodIcon = nil
obj.LeftAirPodIcon = nil

local icons = {
  bothBlack = obj.spoonPath .. "/AirPodsBothTemplate.pdf",
  bothRed = obj.spoonPath .. "/AirPodsBothRed.pdf",
  RightBlack = obj.spoonPath .. "/AirPodsRightTemplate.pdf",
  RightRed = obj.spoonPath .. "/AirPodsRightRed.pdf",
  LeftBlack = obj.spoonPath .. "/AirPodsLeftTemplate.pdf",
  LeftRed = obj.spoonPath .. "/AirPodsLeftRed.pdf",
  magicMouseBlack = obj.spoonPath .. "/MagicMouseTemplate.pdf",
  magicMouseRed = obj.spoonPath .. "/MagicMouseRed.pdf"
}

local function getStatus()
  local icon
  local template

  local airPodsFound
  for _, device in ipairs(Battery.privateBluetoothBatteryInfo()) do
    if device.address == airPodsMacAddress then
      -- primary - the first airpod inserted?
      local primaryInEar = (device.primaryInEar == "YES")
      local secondaryInEar = (device.secondaryInEar == "YES")

      local primaryBud = device.primaryBud
      local secondaryBud
      if primaryBud == "right" then
        primaryBud = "Right"
        secondaryBud = "Left"
      elseif primaryBud == "left" then
        primaryBud = "Left"
        secondaryBud = "Right"
      end

      local primaryBatteryPercent = tonumber(device["batteryPercent" .. primaryBud])
      local secondaryBatteryPercent = tonumber(device["batteryPercent" .. secondaryBud])

      if primaryInEar or secondaryInEar then
        airPodsFound = true
        if primaryInEar and secondaryInEar then
          if (primaryBatteryPercent < 20) or (secondaryBatteryPercent < 20) then
            icon = icons.bothRed
            template = false
          else
            icon = icons.bothBlack
            template = true
          end
        elseif primaryInEar then
          if primaryBatteryPercent < 20 then
            icon = icons[primaryBud .. "Red"]
            template = false
          else
            icon = icons[primaryBud .. "Black"]
            template = true
          end
        elseif secondaryInEar then
          if secondaryBatteryPercent < 20 then
            icon = icons[secondaryBud .. "Red"]
            template = false
          else
            icon = icons[secondaryBud .. "Black"]
            template = true
          end
        end
        obj.airPodsMenuBarItem:returnToMenuBar():setIcon(icon, template)
        break
      end
    end
  end
  if not airPodsFound then
    obj.airPodsMenuBarItem:removeFromMenuBar()
  end

  local magicMouseFound
  for _, device in ipairs(Battery.otherBatteryInfo()) do
    local productName = device.Product
    if productName and productName:find("Magic Mouse") then
      magicMouseFound = true
      if device.BatteryPercent < 20 then
        icon = icons.magicMouseRed
        template = false
      else
        icon = icons.magicMouseBlack
        template = true
      end
      obj.magicMouseMenuBarItem:returnToMenuBar():setIcon(icon, template)
      break
    end
  end
  if not magicMouseFound then
    obj.magicMouseMenuBarItem:removeFromMenuBar()
  end
end

local function delayedTimerCallback()
  getStatus()
end

function obj:start()
  self.pathWatcher:start()
  getStatus()
end

function obj:init()
  self.magicMouseMenuBarItem = Menubar.new()
  self.airPodsMenuBarItem = Menubar.new()
  -- self.delayedTimer = Timer.delayed.new(0.5, delayedTimerCallback)
  self.pathWatcher =
    PathWatcher.new(
    "/Library/Preferences/com.apple.Bluetooth.plist",
    function()
      -- self.delayedTimer:start()
      getStatus()
    end
  )
end

return obj
