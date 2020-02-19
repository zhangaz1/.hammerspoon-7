local ui = require("rb.ui")

local obj = {}

obj.id = "com.apple.reminders"

function obj.pane1(appObj)
  local pane1element = {
    {"AXWindow", 1},
    {"AXSplitGroup", 1},
    {"AXLayoutArea", 1},
    {"AXScrollArea", 1}
  }
  ui.getUIElement(appObj, pane1element):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
  local pane2element = {
    {"AXWindow", 1},
    {"AXSplitGroup", 1},
    {"AXLayoutArea", 2},
    {"AXScrollArea", 1}
  }
  ui.getUIElement(appObj, pane2element):setAttributeValue("AXFocused", true)
end

return obj
