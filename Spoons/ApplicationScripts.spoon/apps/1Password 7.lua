local osascript = require("hs.osascript")
local ui = require("rb.ui")

local obj = {}

obj.id = "com.agilebits.onepassword7"

function obj.toggleCategories(appObj, category)
    -- possible values for category:
    -- WATCHTOWER, CATEGORIES, TAGS
    local cell
    local buttonTitle
    local child2
    local sidebarRows = ui.getUIElement(appObj, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}})
    sidebarRows = sidebarRows:attributeValue("AXChildren")
    for _, row in ipairs(sidebarRows) do
        if row:attributeValue("AXRole") == "AXRow" then
            cell = row:attributeValue("AXChildren")[1]
            child2 = cell:attributeValue("AXChildren")[2]
            if child2 ~= nil then
                if child2:attributeValue("AXRole") == "AXButton" then
                    buttonTitle = cell:attributeValue("AXChildren")[1]:attributeValue("AXValue")
                    if buttonTitle == category then
                        child2:performAction("AXPress")
                        return
                    end
                end
            end
        end
    end
end

function obj.sortBy(appObj)
    local sortByButton = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXUnknown", 2}, {"AXMenuButton", 1}}
    ui.getUIElement(appObj, sortByButton):performAction("AXPress")
end

function obj.convertToLogin()
    osascript.applescript([[
    tell application "System Events"
        tell application process "1Password 7"
            click button "Convert to Login" of group 1 of group 2 of splitter group 1 of splitter group 1 of window 1
        end tell
    end tell]])
end

function obj.pane1(appObj)
    local pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}}
    ui.getUIElement(appObj, pane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
    local pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXTable", 1}}
    ui.getUIElement(appObj, pane2):setAttributeValue("AXFocused", true)
end

return obj
