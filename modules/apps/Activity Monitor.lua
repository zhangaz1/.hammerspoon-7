local hotkey = require('hs.hotkey')
local ax = require("hs._asm.axuielement")
local ui = require("util.ui")

local m = {}

m.id = 'com.apple.ActivityMonitor'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function cycleRadioButtons(direction)
    local win = ax.windowElement(m.thisApp:focusedWindow())
    print(win)
    local radioButtons = {
        {'AXToolbar', 1},
        {'AXGroup', 2},
        {'AXRadioGroup', 1},
    }
    ui.cycleUIElements(win, radioButtons, 'AXRadioButton', direction)
end

m.modal:bind({'cmd'}, 'delete', function() m.thisApp:selectMenuItem({'View', 'Quit Process'}) end)
m.modal:bind({'ctrl', 'shift'}, 'tab', function() cycleRadioButtons('prev') end)
m.modal:bind({'ctrl'}, 'tab', function() cycleRadioButtons('next') end)

return m
