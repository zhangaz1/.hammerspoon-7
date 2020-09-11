local FS = require("hs.fs")
local window = require("hs.window")
local ipc = require("hs.ipc")
local application = require("hs.application")
local hs = hs

----------------------------------
-- HAMMERSPOON SETTINGS, VARIABLES
----------------------------------
require("hs.keycodes").log.setLogLevel("error")
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

---------
-- SPOONS
---------
-- load
local iterFn, dirObj = FS.dir("Spoons/")
if iterFn then
  for file in iterFn, dirObj do
    if string.sub(file, -5) == "spoon" then
      local spoonName = string.sub(file, 1, -7)
      hs.loadSpoon(spoonName)
    end
  end
end

local hyper = {"shift", "cmd", "alt", "ctrl"}

-- ORDER MATTERS!
spoon.AppQuitter.start(
  {
    ["com.kapeli.dashdoc"] = {
      quit = 6,
      hide = 1
    },
    ["com.google.Chrome"] = {
      quit = 4,
      hide = 1
    },
    ["at.obdev.LaunchBar.ActionEditor"] = {
      quit = 0.5,
      hide = 0.2
    },
    ["com.apple.Preview"] = {
      quit = 1,
      hide = 0.2
    },
    ["com.toggl.toggldesktop.TogglDesktop"] = {
      quit = 8,
      hide = 0.2
    },
    ["com.latenightsw.ScriptDebugger7"] = {
      quit = 1,
      hide = 0.2
    },
    ["com.apple.iphonesimulator"] = {
      quit = 1,
      hide = 0.2
    }
  },
  {
    "at.obdev.LaunchBar",
    "com.apple.mail",
    "com.apple.Safari",
    "com.bjango.istatmenus",
    "com.contextsformac.Contexts",
    "com.googlecode.iterm2",
    "desktop.WhatsApp",
    "org.hammerspoon.Hammerspoon",
    "com.sindresorhus.Dato"
  }
)

spoon.AppWatcher:start()
spoon.AppearanceWatcher:start()
spoon.ConfigWatcher:start()
spoon.DownloadsWatcher:start()
spoon.WifiWatcher:start()
spoon.KeyboardLayoutManager:bindHotKeys({toggleInputSource = {{}, 10}})
spoon.Globals:bindHotKeys(
  {
    focusMenuBar = {{"cmd", "shift"}, "1"},
    rightClick = {hyper, "o"}
  }
)
spoon.WindowManager:bindHotKeys(
  {
    pushLeft = {hyper, "left"},
    pushRight = {hyper, "right"},
    pushUp = {hyper, "up"},
    pushDown = {hyper, "down"},
    maximize = {hyper, "return"}
  }
)
spoon.NotificationCenter:bindHotKeys(
  {
    firstButton = {hyper, "1"},
    secondButton = {hyper, "2"},
    thirdButton = {hyper, "3"},
    toggle = {hyper, "n"}
  }
)
