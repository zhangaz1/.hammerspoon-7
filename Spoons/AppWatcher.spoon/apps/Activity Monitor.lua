local hotkey = require('hs.hotkey')
local strictShortcut = require("util.strictShortcut")
local window = require("hs.window")
local osascript = require("hs.osascript")
local ax = require("hs._asm.axuielement")
local ui = require("util.ui")

local m = {}

m.id = 'com.apple.ActivityMonitor'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function trulyFocusedApp()
    print(window.focusedWindow():application():bundleID())
    print(m.id)
    if m.id == window.focusedWindow():application():bundleID() then return true else return false end
end

local function clickActivityMonitorRadioButton(aButton)
    -- osascript.applescript(
    -- string.format([[
    -- tell application "System Events"
    --     tell application process "Activity Monitor"
    --         click radio button %s of radio group 1 of group 2 of toolbar 1 of window 1
    --     end tell
    -- end tell
    -- ]], aButton )
    -- )
    ui.getUIElement(ax.windowElement(m.thisApp:mainWindow()), {
        {"AXToolbar", 1},
        {"AXGroup", 2 },
        {"AXRadioGroup", 1 },
        {"AXRadioButton", tonumber(aButton)}
    }):performAction("AXPress")
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

m.modal:bind({'cmd'}, '1', function() strictShortcut.perform({{'cmd'}, '1'},  m.modal, trulyFocusedApp, clickButton1) end)
m.modal:bind({'cmd'}, '2', function() strictShortcut.perform({{'cmd'}, '2'},  m.modal, trulyFocusedApp, clickButton2) end)
m.modal:bind({'cmd'}, '3', function() strictShortcut.perform({{'cmd'}, '3'},  m.modal, trulyFocusedApp, clickButton3) end)
m.modal:bind({'cmd'}, '4', function() strictShortcut.perform({{'cmd'}, '4'},  m.modal, trulyFocusedApp, clickButton4) end)
m.modal:bind({'cmd'}, '5', function() strictShortcut.perform({{'cmd'}, '5'},  m.modal, trulyFocusedApp, clickButton5) end)

m.modal:bind({'cmd'}, 'delete', function() m.thisApp:selectMenuItem({'View', 'Quit Process'}) end)

return m
