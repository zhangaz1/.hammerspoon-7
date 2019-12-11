local hotkey = require('hs.hotkey')
local ui = require("util.ui")

local m = {}

m.id = 'com.apple.FontBook'
m.thisApp = nil
m.modal = hotkey.modal.new()

local uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
local uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}, {'AXOutline', 1}}
local uiPane3 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXList', 1}, {'AXUnknown', 1}, {'AXGroup', 1}, {'AXGroup', 1}, {'AXTextArea', 1}}

local function pane1()
    ui.getUIElement(m.thisApp, uiPane1):setAttributeValue('AXFocused', true)
end

local function pane2()
    ui.getUIElement(m.thisApp, uiPane2):setAttributeValue('AXFocused', true)
end

local function pane3()
    ui.getUIElement(m.thisApp, uiPane3):setAttributeValue('AXFocused', true)
end

m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)
m.modal:bind({'alt'}, '3', function() pane3() end)

return m
