local osascript = require("hs.osascript")

local ui = require("rb.ui")

local obj = {}

obj.id = "com.apple.Notes"

function obj.searchNotesWithLaunchBar()
  osascript.applescript('tell app "LaunchBar" to perform action "Notes: Search"')
end

function obj.writingDirection(direction)
  local script = string.format([[
  tell application "System Events" to tell application process "Notes" to tell menu bar 1 to tell menu bar item "Format" to tell menu 1 to tell menu item "Text" to tell menu 1 to tell menu item "Writing Direction" to tell menu 1
    click (every menu item whose title contains "%s")
  end tell
  ]], direction)
  osascript.applescript(script)
end

function obj.pane1(appObj)
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

function obj.pane2(appObj)
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

function obj.pane3(appObj)
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

return obj
