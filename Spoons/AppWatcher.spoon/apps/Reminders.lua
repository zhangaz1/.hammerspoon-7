local hotkey = require("hs.hotkey")
local ui = require("util.ui")

local obj = {}
obj.id = "com.apple.reminders"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

local pane1element = {
  {"AXWindow", 1},
  {"AXSplitGroup", 1},
  {"AXLayoutArea", 1},
  {"AXScrollArea", 1}
}

local pane2element = {
  {"AXWindow", 1},
  {"AXSplitGroup", 1},
  {"AXLayoutArea", 2},
  {"AXScrollArea", 1}
}

local function pane1()
  ui.getUIElement(obj.thisApp, pane1element):setAttributeValue("AXFocused", true)
end

local function pane2()
  ui.getUIElement(obj.thisApp, pane2element):setAttributeValue("AXFocused", true)
end

obj.modal:bind(
  {"alt"},
  "1",
  function()
    pane1()
  end
)

obj.modal:bind(
  {"alt"},
  "2",
  function()
    pane2()
  end
)

return obj
