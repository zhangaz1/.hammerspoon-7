local MenuBar = require("hs.menubar")
local Settings = require("hs.settings")
-- https://www.google.com/search?client=safari&rls=en&q=pyobjc+nsstatusbar&ie=UTF-8&oe=UTF-8
-- https://github.com/jaredks/rumps
-- :start(title, input, total)
-- :update(current)
-- :finish(checkmark icon, output)

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

local function toggleAppearanceWatcher(_, menuItem)
  local key = "WatchForAppearanceChange"
  if menuItem.checked then
    Settings.set(key, false)
  else
    Settings.set(key, true)
  end
end

local function toggleVacationMode(_, menuItem)
  local key = "MuteSoundWhenJoiningUnknownNetworks"
  if menuItem.checked then
    Settings.set(key, false)
  else
    Settings.set(key, true)
  end
end

local function menuTable()
  local watchForAppearanceChangeKey = Settings.get("WatchForAppearanceChange")
  local muteSoundForUnknownNetworksKey = Settings.get("MuteSoundWhenJoiningUnknownNetworks")
  local menuTable = {
    { title = "Watch for appearance changes", fn = toggleAppearanceWatcher, checked = watchForAppearanceChangeKey},
    { title = "Mute on unknown networks", fn = toggleVacationMode, checked = muteSoundForUnknownNetworksKey},
  }
  return menuTable
end

local iconPath = obj.spoonPath .. "/statusicon.pdf"

obj.menuBarItem = nil

function obj:init()
  self.menuBarItem = MenuBar.new()
  :setIcon(iconPath)
  :setMenu(menuTable)
end

return obj
