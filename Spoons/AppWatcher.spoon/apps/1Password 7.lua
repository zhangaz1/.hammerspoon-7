local hotkey = require('hs.hotkey')
local osascript = require('hs.osascript')
local ui = require("util.ui")

local m = {}
m.id = 'com.agilebits.onepassword7'
m.thisApp = nil
m.modal = hotkey.modal.new()

local uiSortByBtn = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXUnknown', 2}, {'AXMenuButton', 1}}
local uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
local uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXTable', 1}}
local uiSideBarRows = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}

local function toggleCategories(arg)
    -- possible values for arg:
    -- WATCHTOWER, CATEGORIES, TAGS
    local cell;
    local buttonTitle;
    local child2;
    local sidebarRows = ui.getUIElement(m.thisApp, uiSideBarRows)
    sidebarRows = sidebarRows:attributeValue("AXChildren")
    for _, row in ipairs(sidebarRows) do
        if row:attributeValue('AXRole') == 'AXRow' then
            cell = row:attributeValue('AXChildren')[1]
            child2 = cell:attributeValue('AXChildren')[2]
            if child2 ~= nil then
                if child2:attributeValue('AXRole') == 'AXButton' then
                    buttonTitle = cell:attributeValue('AXChildren')[1]:attributeValue('AXValue')
                    if buttonTitle == arg then
                        child2:performAction('AXPress')
                    end
                end
            end
        end
    end
end

local function sortBy()
    ui.getUIElement(m.thisApp, uiSortByBtn):performAction('AXPress')
end

local function convertToLogin()
    osascript.applescript([[
    tell application "System Events"
        tell application process "1Password 7"
            click button "Convert to Login" of group 1 of group 2 of splitter group 1 of splitter group 1 of window 1
        end tell
    end tell]])
end

local function pane1()
    ui.getUIElement(m.thisApp, uiPane1):setAttributeValue('AXFocused', true)
end

local function pane2()
    ui.getUIElement(m.thisApp, uiPane2):setAttributeValue('AXFocused', true)
end

m.appScripts = {
    { title = 'Toggle Watchtower', func = function() toggleCategories('WATCHTOWER') end },
    { title = 'Toggle Categories', func = function() toggleCategories('CATEGORIES') end },
    { title = 'Toggle Tags', func = function() toggleCategories('TAGS') end },
    { title = "Sort By", func = function() sortBy() end },
    { title = "Convert to Login", func = function() convertToLogin() end }
}

m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)

return m
