local Host = require("hs.host")
local Plist = require("hs.plist")

local obj = {}

local cloudSettingsPlistFile = "settings/cloudSettings.plist"

function obj.labelColor()
  if Host.interfaceStyle() == "Dark" then
    return "#FFFFFF"
  else
    return "#000000"
  end
end

function obj.winBackgroundColor()
  if Host.interfaceStyle() == "Dark" then
    return "#262626"
  else
    return "#E7E7E7"
  end
end

obj.cloudSettings = {
  get = function(key)
    local rootObject = Plist.read(cloudSettingsPlistFile)
    return rootObject[key]
  end,
  set = function(key, value)
    local rootObject = Plist.read(cloudSettingsPlistFile)
    rootObject[key] = value
    Plist.write(cloudSettingsPlistFile, rootObject)
  end
}

return obj
