local ui = require("rb.ui")
local AppleScript = require("hs.osascript").applescript

local obj = {}

obj.id = "com.apple.Preview"

function obj.pane1(appObj)
  local pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXList", 1}}
  ui.getUIElement(appObj, pane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
  local pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}, {"AXGroup", 1}}
  ui.getUIElement(appObj, pane2):setAttributeValue("AXFocused", true)
end

return obj
