local hs = hs
local window = require("hs.window")
local alert = require("hs.alert")
local screen = require("hs.screen")
local ipc = require("hs.ipc")

-------------------
-- PERSONAL MODULES
-------------------
require("modules.appMonitor").init()
require("modules.pathMonitor").init()
require("modules.wifiWatcher").init()
require("modules.forceABC").init()
require("modules.barboy.menuItems")
require("modules.notificationCenter")
require("modules.globalHotkeys")
require("modules.windowManager")
require("modules.NSPanelGoToFolder")

----------------------------------
-- HAMMERSPOON SETTINGS, VARIABLES
----------------------------------
hs.allowAppleScript(true)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.menuIcon(false)
ipc.cliUninstall()
ipc.cliInstall()
window.animationDuration = 0

alert.show("Config Loaded", {atScreenEdge = 1}, screen.mainScreen(), 0.5)
