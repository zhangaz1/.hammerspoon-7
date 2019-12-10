local Menubar = require("hs.menubar")
local PathWatcher = require("hs.pathwatcher")
local Battery = require("hs.battery")
local Timer = require("hs.timer")

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
obj.bluetoothWatcher = nil
obj.airPodsMenuBarIcon = nil
obj.magicMouseMenuBarIcon = nil
obj.bothIcon = nil
obj.rightIcon = nil
obj.leftIcon = nil
obj.magicMouseIcon = nil

local airPodsAddress = "94-16-25-09-80-3c"

function obj:init()
  self.bothIcon = self.spoonPath .. "/AirPodsBothBlack.pdf"
  self.rightIcon = self.spoonPath .. "/airPodBlackRight.pdf"
  self.leftIcon = self.spoonPath .. "/airPodBlackLeft.pdf"
  self.magicMouseIcon = self.spoonPath .. "/MagicMouse.pdf"
  self.airPodsMenuBarIcon = Menubar.new()
  self.magicMouseMenuBarIcon = Menubar.new()
  self.bluetoothWatcher =
    PathWatcher.new(
    "/Library/Preferences/com.apple.Bluetooth.plist",
    function()
      Timer.doAfter(
        1,
        function()
          self:getStatus()
        end
      )
    end
  )
end

function obj:start()
  self.bluetoothWatcher:start()
  self:getStatus()
end

function obj:getStatus()
  local airPodsFound = false
  for _, device in ipairs(Battery.privateBluetoothBatteryInfo()) do
    if device.address == airPodsAddress then
      -- primary -- the first airpod inserted?
      local primaryInEar = (device.primaryInEar == "YES")
      local secondaryInEar = (device.secondaryInEar == "YES")
      if primaryInEar and secondaryInEar then
        self.airPodsMenuBarIcon:returnToMenuBar():setIcon(self.bothIcon)
      elseif primaryInEar then
        self.airPodsMenuBarIcon:returnToMenuBar():setIcon(self.rightIcon)
      elseif secondaryInEar then
        self.airPodsMenuBarIcon:returnToMenuBar():setIcon(self.leftIcon)
      else
        self.airPodsMenuBarIcon:removeFromMenuBar()
      end
      airPodsFound = true
      break
    end
  end
  if not airPodsFound then
    self.airPodsMenuBarIcon:removeFromMenuBar()
  end

  local mouseFound = false
  for _, device in ipairs(Battery.otherBatteryInfo()) do
    if string.find(device.Product, "Magic Mouse") then
      self.magicMouseMenuBarIcon:returnToMenuBar():setIcon(self.magicMouseIcon)
      mouseFound = true
      break
    end
  end
  if not mouseFound then
    self.magicMouseMenuBarIcon:removeFromMenuBar():setIcon(self.magicMouseIcon)
  end
end

return obj
