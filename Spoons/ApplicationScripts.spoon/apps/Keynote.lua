local ui = require("rb.ui")

local obj = {}

obj.id = 'com.apple.iWork.Keynote'

function obj.pane1(appObj)
    ui.getUIElement(appObj, {{'AXWindow', 1}, {'AXScrollArea', 3}}):setAttributeValue('AXFocused', true)
end

function obj.pane2(appObj)
    ui.getUIElement(appObj, {{'AXWindow', 1}, {'AXScrollArea', 2}}):setAttributeValue('AXFocused', true)
end

return obj
