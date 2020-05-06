local MenuBar = require("hs.menubar")
local Application = require("hs.application")
local Settings = require("hs.settings")

local obj = {}

obj.__index = obj
obj.name = "StatusBar"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local spoon = spoon
local appearanceWatcherIsActiveKey = settingKeys.appearanceWatcherActive
local muteSoundForUnknownNetworksKey = settingKeys.muteSoundForUnknownNetworks
local configWatcherIsActiveKey = settingKeys.configWatcherActive

obj.menuBarItem = nil

local tasksStarted
local tasksCompleted

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()

local regularIconPath = obj.spoonPath .. "/statusicon.pdf"
local fadedIconPath = obj.spoonPath .. "/statusicon_faded.pdf"

local function quitHammerspoon()
  Application("Hammerspoon"):kill()
end

local function toggleInputWatcher()
  spoon.InputWatcher:toggle()
end

local function toggleGenericSetting(menuItem, key)
  if menuItem.checked then
    Settings.set(key, false)
  else
    Settings.set(key, true)
  end
end

local function menuTable()
  local dropdownMenuTable = {
    {
      title = "Watch for input events",
      fn = toggleInputWatcher,
      checked = spoon.InputWatcher.watcher:isEnabled()
    },
    {
      title = "Watch for config changes",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, configWatcherIsActiveKey)
      end,
      checked = Settings.get(configWatcherIsActiveKey)
    },
    {
      title = "Watch for appearance changes",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, appearanceWatcherIsActiveKey)
      end,
      checked = Settings.get(appearanceWatcherIsActiveKey)
    },
    {
      title = "Mute on unknown networks",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, muteSoundForUnknownNetworksKey)
      end,
      checked = Settings.get(muteSoundForUnknownNetworksKey)
    },
    {title = "-"},
    {title = "Quit Hammerspoon", fn = quitHammerspoon}
  }
  return dropdownMenuTable
end

local current = "regular"

obj.progress = {}

function obj.progress.start()
  obj.flashingIconTimer:start()
end

function obj.progress.stop()
  obj.flashingIconTimer:stop()
  obj.menuBarItem:setIcon(regularIconPath)
end

function obj:init()
  self.menuBarItem = MenuBar.new():setIcon(regularIconPath):setMenu(menuTable)
  obj.flashingIconTimer = hs.timer.new(
    0.2,
    function()
      if current == "regular" then
        obj.menuBarItem:setIcon(regularIconPath)
        current = "faded"
      else
        obj.menuBarItem:setIcon(fadedIconPath)
        current = "regular"
      end
    end
  )
end

return obj
