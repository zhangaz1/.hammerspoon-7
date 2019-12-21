local AppleScript = require("hs.osascript")
local Plist = require("hs.plist")
local CloudSettings = require("util.cloudSettings")

local mod = {}

local cloudSettings = "settings/cloudSettings.plist"

function mod.setWallpaper(theWallpaper)
  AppleScript.applescript(
    string.format(
      [[
    tell application "System Events" to set picture of (a reference to current desktop) to "%s"
  ]],
      theWallpaper
    )
  )
  CloudSettings.update("currentDesktopShouldBe", theWallpaper)
end

function mod.init()
  local _, currentDesktop, _ =
    AppleScript.applescript([[tell application "System Events" to get picture of (a reference to current desktop)]])
  local currentDesktopShouldBe = Plist.read(cloudSettings).currentDesktopShouldBe
  if currentDesktopShouldBe ~= currentDesktop then
    mod.setWallpaper(currentDesktopShouldBe)
  end
end

return mod
