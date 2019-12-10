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
hs.loadSpoon("ConfigWatcher"):start()

require("modules.forceABC").init()
require("modules.appMonitor").init()
require("modules.wifiWatcher").init()
require("modules.barboy.menuItems")
require("modules.notificationCenter")
require("modules.globalHotkeys")
require("modules.windowManager")

hs.loadSpoon("DownloadsWatcher"):start()
hs.loadSpoon("BluetoothWatcher"):start()
hs.loadSpoon("AppearanceWatcher"):start()
hs.loadSpoon("KSheet")
hs.loadSpoon("MouseGrids")

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
