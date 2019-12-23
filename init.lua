local hs = hs

local FS = require("hs.fs")
local window = require("hs.window")
local alert = require("hs.alert")
local screen = require("hs.screen")
local ipc = require("hs.ipc")
local application = require("hs.application")

hs.logger.defaultLogLevel = "error"
hs.hotkey.setLogLevel("error")

-------------------
-- PERSONAL MODULES
-------------------
require("modules.globalHotkeys")
require("modules.windowManager")
require("WindowManagerModal"):init()

require("util.GlobalChooser"):init()
require("modules.BrightnessControl"):init()

local iterFn, dirObj = FS.dir("Spoons/")
if iterFn then
  for spoon in iterFn, dirObj do
    if string.sub(spoon, -5) == "spoon" then
      hs.loadSpoon(string.sub(spoon, 1, -7))
    end
  end
end

----------------------------------
-- HAMMERSPOON SETTINGS, VARIABLES
----------------------------------
application.enableSpotlightForNameSearches(true)
hs.allowAppleScript(true)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.menuIcon(false)
ipc.cliUninstall()
ipc.cliInstall()
window.animationDuration = 0

alert.show("Config Loaded", {atScreenEdge = 1}, screen.mainScreen(), 0.5)
