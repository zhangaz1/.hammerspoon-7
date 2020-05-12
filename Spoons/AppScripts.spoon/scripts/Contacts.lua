local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")

local obj = {}

obj.id = 'com.apple.AddressBook'

function obj.performContactAction(appObj, button)
  local win = ax.windowElement(appObj:focusedWindow())
  local btn = ui.getUIElement(win, {
    {'AXSplitGroup', 1},
    {'AXButton', button}
  })
  btn:performAction('AXPress')
end

return obj
