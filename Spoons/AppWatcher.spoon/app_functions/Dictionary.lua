local ui = require("rb.ui")

local obj = {}
obj.id = 'com.apple.Dictionary'

function obj.pane1(appObj)
    local pane1A = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXList', 1}}
    local pane1B = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXTable', 1}}
    local t = ui.getUIElement(appObj, pane1A)
    if not t then
        t = ui.getUIElement(appObj, pane1B)
    end
    t:setAttributeValue('AXFocused', true)
end

function obj.pane2(appObj)
    local pane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}, {'AXScrollArea', 1}, {'AXWebArea', 1}}
    ui.getUIElement(appObj, pane2):setAttributeValue('AXFocused', true)
end

return obj
