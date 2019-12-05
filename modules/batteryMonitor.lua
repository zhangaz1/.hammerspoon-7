local menubar = require("hs.menubar")
local PathWatcher = require("hs.pathwatcher")
local Battery = require("hs.battery")

local obj = {}

-- primary -- the first airpod inserted?

local bothIcon = "modules/AirPodsBothBlack.pdf"
local rightIcon = "modules/airPodBlackRight.pdf"
local leftIcon = "modules/airPodBlackLeft.pdf"
local magicMouseIcon = "modules/MagicMouse.pdf"

airPodsMenuBarIcon = nil
magicMouseMenuBarIcon = nil

local airPodsAddress = "94-16-25-09-80-3c"

function obj.getStatus()
  print("Core Bluetooth changed...")
  for _, v in ipairs(Battery.privateBluetoothBatteryInfo()) do
    if v.address == airPodsAddress then
      local primaryInEar = (v.primaryInEar == "YES")
      local secondaryInEar = (v.secondaryInEar == "YES")
      if primaryInEar and secondaryInEar then
        airPodsMenuBarIcon:returnToMenuBar():setIcon(bothIcon)
      elseif primaryInEar then
        airPodsMenuBarIcon:returnToMenuBar():setIcon(rightIcon)
      elseif secondaryInEar then
        airPodsMenuBarIcon:returnToMenuBar():setIcon(leftIcon)
      else
        airPodsMenuBarIcon:removeFromMenuBar()
      end
      return
    end
  end

  magicMouseMenuBarIcon:removeFromMenuBar():setIcon(magicMouseIcon)
  for _, v in ipairs(Battery.otherBatteryInfo()) do
    if string.find( v.Product, "Magic Mouse" ) then
      print("Found"..v.Product)
      magicMouseMenuBarIcon:returnToMenuBar():setIcon(magicMouseIcon)
      break
    end
  end
end

coreBluetoothWatcher = PathWatcher.new( "/Library/Preferences/com.apple.Bluetooth.plist", function() hs.timer.doAfter(1, function() obj.getStatus() end) end)

function obj.init()
  airPodsMenuBarIcon = menubar.new()
  magicMouseMenuBarIcon = menubar.new()
  obj.getStatus()
  coreBluetoothWatcher:start()
end

return obj
