local hotkey = require("hs.hotkey")
local strictShortcut = require("util.strictShortcut")
local window = require("hs.window")
local ax = require("hs._asm.axuielement")
local ui = require("util.ui")

local m = {}

m.id = "com.apple.ActivityMonitor"
m.thisApp = nil
m.modal = hotkey.modal.new()

local function trulyFocusedApp()
  if m.id == window.focusedWindow():application():bundleID() then
    return true
  else
    return false
  end
end

local function clickActivityMonitorRadioButton(aButton)
  ui.getUIElement(
    ax.windowElement(m.thisApp:mainWindow()),
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

m.modal:bind(
  {"cmd"},
  "1",
  function()
    strictShortcut.perform({{"cmd"}, "1"}, m.thisApp, m.modal, nil, clickButton1)
  end
)
m.modal:bind(
  {"cmd"},
  "2",
  function()
    strictShortcut.perform({{"cmd"}, "2"}, m.thisApp, m.modal, nil, clickButton2)
  end
)
m.modal:bind(
  {"cmd"},
  "3",
  function()
    strictShortcut.perform({{"cmd"}, "3"}, m.thisApp, m.modal, nil, clickButton3)
  end
)
m.modal:bind(
  {"cmd"},
  "4",
  function()
    strictShortcut.perform({{"cmd"}, "4"}, m.thisApp, m.modal, nil, clickButton4)
  end
)
m.modal:bind(
  {"cmd"},
  "5",
  function()
    strictShortcut.perform({{"cmd"}, "5"}, m.thisApp, m.modal, nil, clickButton5)
  end
)

m.modal:bind(
  {"cmd"},
  "delete",
  function()
    m.thisApp:selectMenuItem({"View", "Quit Process"})
  end
)

return m
