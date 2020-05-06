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

settingKeys = {
  appearanceWatcherActive = "RBAppearanceWatcherIsActive",
  cachedInterfaceStyle = "RBAppearanceWatcherCachedInterfaceStyle",
  muteSoundForUnknownNetworks = "RBMuteSoundWhenJoiningUnknownNetworks",
  configWatcherActive = "RBConfigWatcherActive",
  processedDownloadsInodes = "RBDownloadsWatcherProcessedDownloadsInodes",
  appsLastActiveKeyboardLayouts = "RBAppsLastActiveKeyboardLayouts",
  safariKeyboardLayoutsPerTab = "RBSafariKeyboardLayoutsPerTab"
}

local settingKeysDefault = {
  appearanceWatcherActive = true,
  cachedInterfaceStyle = hs.host.interfaceStyle() or "Light",
  muteSoundForUnknownNetworks = true,
  configWatcherActive = true,
  processedDownloadsInodes = {},
  appQuitterUnterminatedTimers = {},
  appsLastActiveKeyboardLayouts = {},
  safariKeyboardLayoutsPerTab = {}
}

for i, v in pairs(settingKeys) do
  if hs.settings.get(v) == nil then
    hs.settings.set(v, settingKeysDefault[i])
  end
end

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
