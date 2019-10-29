local hotkey = require('hs.hotkey')
local ax = require("hs._asm.axuielement")
local eventtap = require("hs.eventtap")

local m = {}
m.id = 'com.apple.Stickies'
m.thisApp = nil
m.modal = hotkey.modal.new()

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


m.modal:bind({'cmd'}, 'd', function() textCompletion() end)

return m
