local hotkey = require("hs.hotkey")
local ax = require("hs._asm.axuielement")

local mod = {}

mod.id = 'at.obdev.LaunchBar.ActionEditor'
mod.thisApp = nil
mod.modal = hotkey.modal.new()

local function pane1()
    ax.windowElement(mod.thisApp:focusedWindow()):searchPath({
        { role = "AXGroup" },
        { role = "AXSplitGroup" },
        { role = "AXScrollArea" },
        { role = "AXOutline" },
    }):setAttributeValue('AXFocused', true)
end

local function pane2()
    ax.windowElement(mod.thisApp:focusedWindow()):searchPath({
        { role = "AXGroup" },
        { role = "AXSplitGroup" },
        { role = "AXGroup" },
        { role = "AXScrollArea" },
        { role = "AXTextField" },
    }):setAttributeValue('AXFocused', true)
end

mod.modal:bind({'alt'}, '1', function() pane1() end)
mod.modal:bind({'alt'}, '2', function() pane2() end)

return mod
