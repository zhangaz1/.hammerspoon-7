local hs = hs

local FS = require("hs.fs")
local window = require("hs.window")
local alert = require("hs.alert")
local screen = require("hs.screen")
local ipc = require("hs.ipc")
local application = require("hs.application")
-- local spoon = spoon

hs.logger.defaultLogLevel = "error"
hs.hotkey.setLogLevel("error")

-------------------
-- PERSONAL MODULES
-------------------
local iterFn, dirObj = FS.dir("Spoons/")
if iterFn then
  for file in iterFn, dirObj do
    if string.sub(file, -5) == "spoon" then
      local spoonName = string.sub(file, 1, -7)
      -- if not spoon[spoonName] then
        hs.loadSpoon(spoonName)
      -- end
    elseif file:sub(-4) == ".lua" then
      require("Spoons." .. file:sub(1, -5))
    end
  end
end

spoon.AppWatcher:start()
spoon.WifiWatcher:start()
spoon.BluetoothWatcher:start()
spoon.ConfigWatcher:start()
spoon.AppearanceWatcher:start()
spoon.BluetoothWatcher:start()
spoon.InputSourceGuard:start()
spoon.InputWatcher:start()
spoon.DownloadsWatcher:start()
spoon.Hotkeys:start()

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
