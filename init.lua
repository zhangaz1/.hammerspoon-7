local hs = hs

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
require("modules.reloadConfigWatcher").init()
require("modules.forceABC").init()
require("modules.appMonitor").init()
require("modules.wifiWatcher").init()
require("modules.appearance").init()
require("modules.batteryMonitor").init()

require("modules.barboy.menuItems")
require("modules.notificationCenter")
require("modules.globalHotkeys")
require("modules.windowManager")

require("MouseGrids").init()

hs.loadSpoon("KSheet")
hs.loadSpoon("DownloadsListener"):start()

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
