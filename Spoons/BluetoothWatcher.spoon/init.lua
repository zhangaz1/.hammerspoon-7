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
obj.pathwatcher = nil
obj.airPodsMenuBarItem = nil
obj.magicMouseMenuBarItem = nil
obj.airPodsMacAddress = "94-16-25-09-80-3c"
obj.bothIcon = obj.spoonPath .. "/AirPodsBothBlack.pdf"
obj.rightIcon = obj.spoonPath .. "/airPodBlackRight.pdf"
obj.leftIcon = obj.spoonPath .. "/airPodBlackLeft.pdf"
obj.magicMouseIcon = obj.spoonPath .. "/MagicMouse.pdf"

function obj:init()
  self.airPodsMenuBarItem = Menubar.new()
  self.magicMouseMenuBarItem = Menubar.new()
  self.pathwatcher =
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
  ):start()
  self:getStatus()
end

function obj:getStatus()
  local airPodsFound = false
  for _, device in ipairs(Battery.privateBluetoothBatteryInfo()) do
    if device.address == obj.airPodsMacAddress then
      -- primary -- the first airpod inserted?
      local primaryInEar = (device.primaryInEar == "YES")
      local secondaryInEar = (device.secondaryInEar == "YES")
      if primaryInEar and secondaryInEar then
        self.airPodsMenuBarItem:returnToMenuBar():setIcon(self.bothIcon)
      elseif primaryInEar then
        self.airPodsMenuBarItem:returnToMenuBar():setIcon(self.rightIcon)
      elseif secondaryInEar then
        self.airPodsMenuBarItem:returnToMenuBar():setIcon(self.leftIcon)
      else
        self.airPodsMenuBarItem:removeFromMenuBar()
      end
      airPodsFound = true
      break
    end
  end
  if not airPodsFound then
    self.airPodsMenuBarItem:removeFromMenuBar()
  end

  local mouseFound = false
  for _, device in ipairs(Battery.otherBatteryInfo()) do
    if string.find(device.Product, "Magic Mouse") then
      self.magicMouseMenuBarItem:returnToMenuBar():setIcon(self.magicMouseIcon)
      mouseFound = true
      break
    end
  end
  if not mouseFound then
    self.magicMouseMenuBarItem:removeFromMenuBar():setIcon(self.magicMouseIcon)
  end
end

return obj
