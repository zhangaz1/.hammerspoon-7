local hotkey = require('hs.hotkey')
local ui = require("util.ui")

local m = {}
m.id = 'com.apple.iTunes'
m.thisApp = nil
m.modal = hotkey.modal.new()

m.uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
m.uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}}

local function pane1()
    return ui.getUIElement(m.thisApp, m.uiPane1):setAttributeValue('AXFocused', true)
end

local function pane2()
    return ui.getUIElement(m.thisApp, m.uiPane2):attributeValue('AXChildren')[1]:setAttributeValue('AXFocused', true)
end

local function cycleRadioButtons(arg)
    return ui.cycleUIElements(m.thisApp, {{'AXWindow', 1}, {'AXRadioGroup', 1}}, 'AXRadioButton', arg)
end

m.modal:bind({'cmd, alt'}, 'right', function() cycleRadioButtons('next') end)
m.modal:bind({'cmd, alt'}, 'left', function() cycleRadioButtons('prev') end)
m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)

return m
