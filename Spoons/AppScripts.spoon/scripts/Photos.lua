local ui = require("rb.ui")

local obj = {}
obj.id = "com.apple.Photos"

function obj.pane1(appObj)
  local uiPane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}}
  ui.getUIElement(appObj, uiPane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
  local uiPane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}}
  ui.getUIElement(appObj, uiPane2):setAttributeValue("AXFocused", true)
end

return obj
