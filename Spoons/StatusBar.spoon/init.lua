local HSApplication = require("hs.application")
local HSMenubar = require("hs.menubar")
local HSSettings = require("hs.settings")
local HSTimer = require("hs.timer")
local HSURLEvent = require("hs.urlevent")
local spoon = spoon

local obj = {}

obj.__index = obj
obj.name = "StatusBar"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()

local regularIconPath = obj.spoonPath .. "/statusicon.pdf"
local fadedIconPath = obj.spoonPath .. "/statusicon_faded.pdf"

local appearanceWatcherIsActiveKey = settingKeys.appearanceWatcherActive
local muteSoundForUnknownNetworksKey = settingKeys.muteSoundForUnknownNetworks
local configWatcherIsActiveKey = settingKeys.configWatcherActive

obj.menuBarItem = nil
obj.flashingIconTimer = nil
obj.taskQueue = 0

local function quitHammerspoon()
  HSApplication("Hammerspoon"):kill()
end

local function toggleInputWatcher()
  spoon.InputWatcher:toggle()
end

local function toggleGenericSetting(menuItem, key)
  if menuItem.checked then
    HSSettings.set(key, false)
  else
    HSSettings.set(key, true)
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
      checked = HSSettings.get(configWatcherIsActiveKey)
    },
    {
      title = "Watch for appearance changes",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, appearanceWatcherIsActiveKey)
      end,
      checked = HSSettings.get(appearanceWatcherIsActiveKey)
    },
    {
      title = "Mute on unknown networks",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, muteSoundForUnknownNetworksKey)
      end,
      checked = HSSettings.get(muteSoundForUnknownNetworksKey)
    },
    {title = "-"},
    {title = "Quit Hammerspoon", fn = quitHammerspoon}
  }
  return dropdownMenuTable
end

local current = "regular"

obj.progress = {}

function obj.progress.start()
  if not obj.flashingIconTimer:running() then
    obj.flashingIconTimer:start()
  end
  obj.taskQueue = obj.taskQueue + 1
end

function obj.progress.stop()
  obj.taskQueue = obj.taskQueue - 1
  if obj.taskQueue < 1 then
    obj.menuBarItem:setIcon(regularIconPath)
    obj.flashingIconTimer:stop()
  end
end

function obj:init()
  obj.menuBarItem = HSMenubar.new():setIcon(regularIconPath):setMenu(menuTable)
  obj.flashingIconTimer =
    HSTimer.new(
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
  HSURLEvent.bind("start-task-with-progress", obj.progress.start)
  HSURLEvent.bind("stop-task-with-progress", obj.progress.stop)
end

return obj
