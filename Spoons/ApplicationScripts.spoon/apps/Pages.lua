local osascript = require("hs.osascript")

local ui = require("rb.ui")

local obj = {}

obj.id = "com.apple.iWork.Pages"

function obj.fontFamily()
	osascript.applescript([[
		tell application "System Events"
			tell application process "Pages"
				click (first pop up button whose help = "Choose the font family.") of scroll area 2 of splitter group 1 of window 1
			end tell
		end tell
	]])
end

function obj.paragraphStyle()
	osascript.applescript([[
		tell application "System Events"
			tell application process "Pages"
				click (first button whose help = "Choose a style to apply to a paragraph.") of splitter group 1 of window 1
			end tell
		end tell
	]])
end

function obj.pane1(appObj)
	-- pane1 is either the main text area, or the sidebar, if open
	ui.getUIElement(appObj, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}}):setAttributeValue("AXFocused", true)
end

return obj
