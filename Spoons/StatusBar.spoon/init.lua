local HSApplication = require("hs.application")
local HSMenubar = require("hs.menubar")
local HSTimer = require("hs.timer")
local HSURLEvent = require("hs.urlevent")
local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

obj.__index = obj
obj.name = "StatusBar"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local spoonPath = script_path()
local regularIconPath = spoonPath .. "/statusicon.pdf"
local fadedIconPath = spoonPath .. "/statusicon_faded.pdf"
local current = "regular"

obj.progress = {}
obj.menuBarItem = nil
obj.flashingIconTimer = nil
obj.taskQueue = 0

local function menuTable()
  local dropdownMenuTable = {
    -- {
    --   title = "Watch for input events",
    --   fn = function()
    --     spoon.InputWatcher:toggle()
    --   end,
    --   checked = spoon.InputWatcher.watcher:isEnabled()
    -- },
    {
      title = "Watch for config changes",
      fn = function()
        spoon.ConfigWatcher:toggle()
      end,
      checked = spoon.ConfigWatcher:isActive()
    },
    {
      title = "Watch for appearance changes",
      fn = function()
        spoon.AppearanceWatcher:toggle()
      end,
      checked = spoon.AppearanceWatcher:isActive()
    },
    {
      title = "Mute on unknown networks",
      fn = function()
        spoon.WifiWatcher:toggle()
      end,
      checked = spoon.WifiWatcher:isActive()
    },
    {title = "-"},
    {
      title = "Quit Hammerspoon",
      fn = function()
        HSApplication("Hammerspoon"):kill()
      end
    }
  }
  return dropdownMenuTable
end

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
