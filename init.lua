local FS = require("hs.fs")
local window = require("hs.window")
local ipc = require("hs.ipc")
local application = require("hs.application")

local hs = hs

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

----------
-- LOGGING
----------
require("hs.keycodes").log.setLogLevel("error")

------------------
-- GLOBAL SETTINGS
------------------
-- load spoons
local iterFn, dirObj = FS.dir("Spoons/")
if iterFn then
  for file in iterFn, dirObj do
    if string.sub(file, -5) == "spoon" then
      local spoonName = string.sub(file, 1, -7)
      hs.loadSpoon(spoonName)
    end
  end
end

spoon.AppQuitter:start()
spoon.AppWatcher:start()
spoon.AppearanceWatcher:start()
spoon.ConfigWatcher:start()
spoon.DownloadsWatcher:start()
spoon.WifiWatcher:start()
