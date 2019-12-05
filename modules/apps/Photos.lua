local hotkey = require('hs.hotkey')
local ui = require("util.ui")

local m = {}
m.id = 'com.apple.Photos'
m.thisApp = nil
m.modal = hotkey.modal.new()

local uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}}
local uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}}

m.modal:bind({'alt'}, '1', function() ui.getUIElement(m.thisApp, uiPane1):setAttributeValue('AXFocused', true) end)
m.modal:bind({'alt'}, '2', function() ui.getUIElement(m.thisApp, uiPane2):setAttributeValue('AXFocused', true) end)

return m
