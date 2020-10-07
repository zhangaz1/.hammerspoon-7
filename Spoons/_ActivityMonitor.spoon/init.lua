--- === ActivityMonitor ===
---
--- Activity Monitor.app automations.

local Hotkey = require("hs.hotkey")
local ax = require("hs.axuielement")
local ui = require("rb.ui")

local obj = {}
local _modal = nil
local _appObj = nil

obj.__index = obj
obj.name = "ActivityMonitor"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "com.apple.ActivityMonitor"

local function clickActivityMonitorRadioButton(appObj, aButton)
  ui.getUIElement(
    ax.windowElement(appObj:mainWindow()),
    {
      {"AXToolbar", 1},
      {"AXGroup", 2},
      {"AXRadioGroup", 1},
      {"AXRadioButton", tonumber(aButton)}
    }
  ):performAction("AXPress")
end

local hotkeys = {
  {
    "cmd",
    "1",
    function()
      clickActivityMonitorRadioButton(_appObj, 1)
    end
  },
  {
    "cmd",
    "2",
    function()
      clickActivityMonitorRadioButton(_appObj, 2)
    end
  },
  {
    "cmd",
    "3",
    function()
      clickActivityMonitorRadioButton(_appObj, 3)
    end
  },
  {
    "cmd",
    "4",
    function()
      clickActivityMonitorRadioButton(_appObj, 4)
    end
  },
  {
    "cmd",
    "5",
    function()
      clickActivityMonitorRadioButton(_appObj, 5)
    end
  },
  {
    "cmd",
    "delete",
    function()
      _appObj:selectMenuItem({"View", "Quit Process"})
    end
  }
}

function obj:start(appObj)
  _appObj = appObj
  _modal:enter()
end

function obj:stop()
  _modal:exit()
end

function obj:init()
  if not obj.bundleID then
    hs.showError("bundle indetifier for app spoon is nil")
  end
  _modal = Hotkey.modal.new()
  for _, v in ipairs(hotkeys) do
    _modal:bind(table.unpack(v))
  end
end

return obj
