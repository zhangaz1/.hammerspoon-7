local Plist = require("hs.plist")

local mod = {}

local cloudSettingsPlistFile = "settings/cloudSettings.plist"

function mod.update(key, value)
  local rootObject = Plist.read(cloudSettingsPlistFile)
  rootObject[key] = value
  Plist.write(cloudSettingsPlistFile, rootObject)
end

return mod
