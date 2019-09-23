local hotkey = require('hs.hotkey')
local ax = require("hs._asm.axuielement")
local ui = require("util.ui")
local eventtap = require("hs.eventtap")
local osascript = require("hs.osascript")

local m = {}
m.id = 'com.apple.Notes'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function writingDirection(direction)
    osascript.applescript([[
        tell application "System Events"
            tell application process "Notes"
                tell menu bar 1
                    tell menu bar item "Format"
                        tell menu 1
                            tell menu item "Text"
                                tell menu 1
                                    tell menu item "Writing Direction"
                                        tell menu 1
                                            click (every menu item whose title contains "]]..direction..[[")
                                        end tell
                                    end tell
                                end tell
                            end tell
                        end tell
                    end tell
                end tell
            end tell
        end tell
    ]])
end
local function pane1()
    ui.getUIElement(m.thisApp, {
        {'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}
    }):setAttributeValue('AXFocused', true)
end

local function pane2()
    ui.getUIElement(m.thisApp, {
        {'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXTable', 1}
    }):setAttributeValue('AXFocused', true)
end

local function pane3()
    ui.getUIElement(m.thisApp, {
        {'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 2}, {'AXScrollArea', 1}, {'AXTextArea', 1}
    }):setAttributeValue('AXFocused', true)
end

local function textCompletion()
    local trulyFocusedAppIdentifier = hs.window.focusedWindow():application():bundleID()
    local writingAreaAXIdentifier = ax.applicationElement(m.thisApp):focusedUIElement():attributeValue('AXRole')
	if (writingAreaAXIdentifier ~= 'AXTextArea') or (trulyFocusedAppIdentifier ~= m.id) then
		m.modal:exit()
		eventtap.keyStroke({}, 'tab')
		m.modal:enter()
	else
		eventtap.keyStroke({}, 'f5')
	end
end


m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)
m.modal:bind({'alt'}, '3', function() pane3() end)
m.modal:bind({'cmd'}, 'd', function() textCompletion() end)

m.appScripts = {
    {title = 'Left to Right Writing Direction', func = function() writingDirection("Left to Right") end},
    {title = 'Right to Left Writing Direction', func = function() writingDirection("Right to Left") end}
}

return m
