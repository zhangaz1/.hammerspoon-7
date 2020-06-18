local osascript = require("hs.osascript")
local ui = require("rb.ui")

local obj = {}

obj.id = "com.apple.Notes"

function obj.searchNotesWithLaunchBar()
  print("foo")
  osascript.applescript('tell app "LaunchBar" to perform action "Notes: Search"')
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
