local hs = hs

local FS = require("hs.fs")
local window = require("hs.window")
local alert = require("hs.alert")
local screen = require("hs.screen")
local ipc = require("hs.ipc")
local application = require("hs.application")
local settings = require("hs.settings")

----------------------------------
-- HAMMERSPOON SETTINGS, VARIABLES
----------------------------------
application.enableSpotlightForNameSearches(true)
hs.allowAppleScript(true)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.hotkey.setLogLevel("error")
hs.logger.defaultLogLevel = "error"
hs.menuIcon(false)
ipc.cliUninstall()
ipc.cliInstall()
window.animationDuration = 0

-------------------
-- PERSONAL MODULES
-------------------
local iterFn, dirObj = FS.dir("Spoons/")
if iterFn then
  for file in iterFn, dirObj do
    if string.sub(file, -5) == "spoon" then
      local spoonName = string.sub(file, 1, -7)
        hs.loadSpoon(spoonName)
    end
  end
end

alert.show("Config Loaded", {atScreenEdge = 1}, screen.mainScreen(), 0.5)
