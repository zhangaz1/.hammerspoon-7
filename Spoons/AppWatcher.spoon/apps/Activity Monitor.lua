local hotkey = require("hs.hotkey")
local window = require("hs.window")

local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")
local Util = require("rb.util")

local obj = {}

obj.id = "com.apple.ActivityMonitor"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

local function trulyFocusedApp()
  if obj.id == window.focusedWindow():application():bundleID() then
    return true
  else
    return false
  end
end

local function clickActivityMonitorRadioButton(aButton)
  ui.getUIElement(
    ax.windowElement(obj.thisApp:mainWindow()),
    {
      {"AXToolbar", 1},
      {"AXGroup", 2},
      {"AXRadioGroup", 1},
      {"AXRadioButton", tonumber(aButton)}
    }
  ):performAction("AXPress")
end

local function clickButton1()
  clickActivityMonitorRadioButton(1)
end
local function clickButton2()
  clickActivityMonitorRadioButton(2)
end
local function clickButton3()
  clickActivityMonitorRadioButton(3)
end
local function clickButton4()
  clickActivityMonitorRadioButton(4)
end
local function clickButton5()
  clickActivityMonitorRadioButton(5)
end

obj.modal:bind(
  {"cmd"},
  "1",
  function()
    Util.strictShortcut({{"cmd"}, "1"}, obj.thisApp, obj.modal, nil, clickButton1)
  end
)
obj.modal:bind(
  {"cmd"},
  "2",
  function()
    Util.strictShortcut({{"cmd"}, "2"}, obj.thisApp, obj.modal, nil, clickButton2)
  end
)
obj.modal:bind(
  {"cmd"},
  "3",
  function()
    Util.strictShortcut({{"cmd"}, "3"}, obj.thisApp, obj.modal, nil, clickButton3)
  end
)
obj.modal:bind(
  {"cmd"},
  "4",
  function()
    Util.strictShortcut({{"cmd"}, "4"}, obj.thisApp, obj.modal, nil, clickButton4)
  end
)
obj.modal:bind(
  {"cmd"},
  "5",
  function()
    Util.strictShortcut({{"cmd"}, "5"}, obj.thisApp, obj.modal, nil, clickButton5)
  end
)

obj.modal:bind(
  {"cmd"},
  "delete",
  function()
    obj.thisApp:selectMenuItem({"View", "Quit Process"})
  end
)

return obj
