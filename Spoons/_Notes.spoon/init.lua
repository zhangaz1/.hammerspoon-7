--- === Notes ===
---
--- Notes.app automations.

local Hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local ui = require("rb.ui")

local obj = {}
local _modal = nil
local _appObj = nil

obj.__index = obj
obj.name = "Notes"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "com.apple.Notes"

local function searchNotesWithLaunchBar()
  osascript.applescript('tell app "LaunchBar" to perform action "Notes: Search"')
end

local function pane1(appObj)
  ui.getUIElement(
    appObj,
    {
      {"AXWindow", 1},
      {"AXSplitGroup", 1},
      {"AXScrollArea", 1},
      {"AXOutline", 1}
    }
  ):setAttributeValue("AXFocused", true)
end

local function pane2(appObj)
  ui.getUIElement(
    appObj,
    {
      {"AXWindow", 1},
      {"AXSplitGroup", 1},
      {"AXSplitGroup", 1},
      {"AXScrollArea", 1}
    }
  ):setAttributeValue("AXFocused", true)
end

local function pane3(appObj)
  ui.getUIElement(
    appObj,
    {
      {"AXWindow", 1},
      {"AXSplitGroup", 1},
      {"AXSplitGroup", 1},
      {"AXGroup", 1},
      {"AXScrollArea", 1},
      {"AXTextArea", 1}
    }
  ):setAttributeValue("AXFocused", true)
end

local hotkeys = {
  {
    "alt",
    "1",
    function()
      pane1(_appObj)
    end
  },
  {
    "alt",
    "2",
    function()
      pane2(_appObj)
    end
  },
  {
    "alt",
    "3",
    function()
      pane3(_appObj)
    end
  },
  {
    {"shift", "cmd"},
    "o",
    function()
      searchNotesWithLaunchBar()
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
