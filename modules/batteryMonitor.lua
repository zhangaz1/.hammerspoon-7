local plist = require("hs.plist")
local menubar = require("hs.menubar")
local pathwatcher = require("hs.pathwatcher")

local obj = {}

-- local data = hs.battery.privateBluetoothBatteryInfo()
-- hs.inspect(data)

-- primary -- the right airpod?
-- PrimaryInEar = 0/1/2
-- SecondaryInEar = 0/3/2

local bothIcon = "modules/AirPodsBothBlack.pdf"
local rightIcon = "modules/airPodBlackRight.pdf"
local leftIcon = "modules/airPodBlackLeft.pdf"

obj.menuBarIcon = nil
obj.btPlist = '/Library/Preferences/com.apple.Bluetooth.plist'

function obj.getStatus()
  local data = plist.read(obj.btPlist)
  for _,v in pairs(data.DeviceCache) do
      local deviceName = v.displayName
      if deviceName then
        if string.find( string.lower(deviceName), "airpods" ) then
          -- print(hs.inspect(v))
          obj.menuBarIcon:removeFromMenuBar()
          if v.InEar then
            local primaryInEar = (tonumber(v.PrimaryInEar) > 0)
            local secondaryInEar = (tonumber(v.SecondaryInEar) > 0)
            print(primaryInEar, secondaryInEar)
            if primaryInEar and secondaryInEar then
              -- print(v.BatteryPercentLeft, v.BatteryPercentRight)
              obj.menuBarIcon:setIcon(bothIcon):returnToMenuBar()
            elseif primaryInEar then
              obj.menuBarIcon:setIcon(rightIcon):returnToMenuBar()
            elseif secondaryInEar then
              obj.menuBarIcon:setIcon(leftIcon):returnToMenuBar()
            end
          end
        end
      end
  end
 end

obj.watcher = pathwatcher.new(obj.btPlist, function() obj.getStatus() end)

function obj.init()
  obj.menuBarIcon = menubar.new()
  obj.getStatus()
  obj.watcher:start()
end

return obj
