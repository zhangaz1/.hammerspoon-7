local hotkey = require('hs.hotkey')
local osascript = require('hs.osascript')
local ui = require("util.ui")

local m = {}
m.id = 'com.apple.iWork.Pages'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function fontFamily()
	osascript.applescript([[
		tell application "System Events"
			tell application process "Pages"
				click (first pop up button whose help = "Choose the font family.") of scroll area 2 of splitter group 1 of window 1
			end tell
		end tell
	]])
end

local function paragraphStyle()
	osascript.applescript([[
		tell application "System Events"
			tell application process "Pages"
				click (first button whose help = "Choose a style to apply to a paragraph.") of splitter group 1 of window 1
			end tell
		end tell
	]])
end

local function pane1()
	-- pane1 is either the main text area, or the sidebar, if open
	ui.getUIElement(m.thisApp, {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}}):setAttributeValue('AXFocused', true)
end


m.appScripts = {
	{ title = "Font Family", func = function() fontFamily() end },
	{ title = "Paragraph Style", func = function() paragraphStyle() end }
}

m.modal:bind({'alt'}, '1', function() pane1() end)

return m
