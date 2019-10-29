local hotkey = require('hs.hotkey')
local ui = require("util.ui")

local m = {}

m.id = 'com.latenightsw.ScriptDebugger7'
m.thisApp = nil
m.modal = hotkey.modal.new()

m.uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
m.uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
m.uiPane3 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXWebArea', 1}}

m.modal:bind({'alt'}, '1', function() ui.getUIElement(m.thisApp, m.uiPane1):setAttributeValue('AXFocused', true) end)
m.modal:bind({'alt'}, '2', function() ui.getUIElement(m.thisApp, m.uiPane2):setAttributeValue('AXFocused', true) end)
m.modal:bind({'alt'}, '3', function() ui.getUIElement(m.thisApp, m.uiPane3):setAttributeValue('AXFocused', true) end)

return m
