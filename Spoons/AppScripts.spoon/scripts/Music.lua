local ui = require("rb.ui")

local obj = {}
obj.id = "com.apple.Music"

function obj.pane1(appObj)
    local pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
    return ui.getUIElement(appObj, pane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
    local pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}}
    return ui.getUIElement(appObj, pane2):attributeValue("AXChildren")[1]:setAttributeValue("AXFocused", true)
end

function obj.focusFilterField(appObj)
    local filterField = ui.getUIElement(appObj, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXTextField", 1}})
    if not filterField then
        appObj:selectMenuItem({"View", "Show Filter Field"})
    else
        filterField:setAttributeValue("AXFocused", true)
    end

end

return obj
