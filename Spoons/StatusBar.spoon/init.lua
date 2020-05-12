local hs = hs
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
  hs.application("Hammerspoon"):kill()
end

local function toggleInputWatcher()
  spoon.InputWatcher:toggle()
end

local function toggleGenericSetting(menuItem, key)
  if menuItem.checked then
    hs.settings.set(key, false)
  else
    hs.settings.set(key, true)
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
      checked = hs.settings.get(configWatcherIsActiveKey)
    },
    {
      title = "Watch for appearance changes",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, appearanceWatcherIsActiveKey)
      end,
      checked = hs.settings.get(appearanceWatcherIsActiveKey)
    },
    {
      title = "Mute on unknown networks",
      fn = function(_, menuItem)
        toggleGenericSetting(menuItem, muteSoundForUnknownNetworksKey)
      end,
      checked = hs.settings.get(muteSoundForUnknownNetworksKey)
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
  obj.menuBarItem = hs.menubar.new():setIcon(regularIconPath):setMenu(menuTable)
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
  -- hs.urlevent
end

return obj
