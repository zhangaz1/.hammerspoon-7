local hotkey = require('hs.hotkey')
local ui = require("util.ui")


local m = {}
m.id = 'com.apple.iWork.Keynote'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function pane1()
    ui.getUIElement(m.thisApp, {{'AXWindow', 1}, {'AXScrollArea', 3}}):setAttributeValue('AXFocused', true)
end

local function pane2()
    ui.getUIElement(m.thisApp, {{'AXWindow', 1}, {'AXScrollArea', 2}}):setAttributeValue('AXFocused', true)
end

m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)

return m
