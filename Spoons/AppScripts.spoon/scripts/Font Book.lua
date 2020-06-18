local ui = require("rb.ui")

local obj = {}

obj.id = "com.apple.FontBook"

function obj.pane1(appObj)
    local pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
    ui.getUIElement(appObj, pane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
    local pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}, {"AXOutline", 1}}
    ui.getUIElement(appObj, pane2):setAttributeValue("AXFocused", true)
end

function obj.pane3(appObj)
    local pane3 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXList", 1}, {"AXUnknown", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXTextArea", 1}}
    ui.getUIElement(appObj, pane3):setAttributeValue("AXFocused", true)
end

return obj
