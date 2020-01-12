local Menubar = require("hs.menubar")
local PathWatcher = require("hs.pathwatcher")
local Battery = require("hs.battery")
local Timer = require("hs.timer")

local Chooser = require("rb.fuzzychooser")
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
  bothBlack = obj.spoonPath .. "/AirPodsBothBlack.pdf",
  bothRed = obj.spoonPath .. "/AirPodsBothRed.pdf",
  RightBlack = obj.spoonPath .. "/AirPodsRightBlack.pdf",
  LeftBlack = obj.spoonPath .. "/AirPodsLeftBlack.pdf",
  magicMouseBlack = obj.spoonPath .. "/MagicMouseBlack.pdf",
  magicMouseRed = obj.spoonPath .. "/MagicMouseRed.pdf"
}

local devices = {}

local function getStatus()
  local airPodsFound
  local magicMouseFound
  local icon
  local template
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
        table.insert(
          devices,
          {
            text = device.name,
            address = device.address
          }
        )
        airPodsFound = true
        if primaryInEar and secondaryInEar then
          if (primaryBatteryPercent < 20) and (secondaryBatteryPercent < 20) then
            icon = icons.bothRed
            template = false
          elseif (primaryBatteryPercent > 20) and (secondaryBatteryPercent > 20) then
            icon = icons.bothBlack
            template = true
          elseif (primaryBatteryPercent > 20) and (secondaryBatteryPercent < 20) then
          elseif (primaryBatteryPercent < 20) and (secondaryBatteryPercent > 20) then
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

  for _, device in ipairs(Battery.otherBatteryInfo()) do
    local productName = device.Product
    if productName:find("Magic Mouse") then
      table.insert(
        devices,
        {
          text = productName,
          address = device.DeviceAddress
        }
      )
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

local function chooserCallback(choice)
  if choice then
    print(choice)
  end
end

function obj.start()
  Chooser:start(chooserCallback, devices, {"text"})
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
      -- getStatus()
    end
  ):start()
  getStatus()
end

return obj
