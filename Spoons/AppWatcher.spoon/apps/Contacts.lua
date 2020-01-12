local hotkey = require('hs.hotkey')

local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")

local m = {}
m.id = 'com.apple.AddressBook'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function performContactAction(button)
    local win = ax.windowElement(m.thisApp:focusedWindow())
    local btn = ui.getUIElement(win, {
        {'AXSplitGroup', 1},
        {'AXButton', button}
    })
    btn:performAction('AXPress')
end

m.modal:bind({'cmd'}, '1', function() performContactAction(4) end)
m.modal:bind({'cmd'}, '2', function() performContactAction(5) end)
m.modal:bind({'cmd'}, '3', function() performContactAction(6) end)
m.modal:bind({'cmd'}, '4', function() performContactAction(7) end)

return m
