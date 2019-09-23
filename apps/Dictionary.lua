local ui = require("util.ui")

local hotkey = require('hs.hotkey')

local m = {}
m.id = 'com.apple.Dictionary'
m.thisApp = nil
m.modal = hotkey.modal.new()

local uiPane1a = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXList', 1}}
local uiPane1b = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXTable', 1}}
local uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}, {'AXScrollArea', 1}, {'AXWebArea', 1}}

local function pane1()
    local t = ui.getUIElement(m.thisApp, uiPane1a)
    if not t then
        t = ui.getUIElement(m.thisApp, uiPane1b)
    end
    t:setAttributeValue('AXFocused', true)
end

local function pane2()
    ui.getUIElement(m.thisApp, uiPane2):setAttributeValue('AXFocused', true)
end

m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)

return m
