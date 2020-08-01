local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local ui = require("rb.ui")

local obj = {}

obj.id = "com.apple.mail"

local function getSelectedMessages()
	local _, messageIds, _ = osascript.applescript([[
        set msgId to {}
        tell application "Mail" to set _selected to selection
        repeat with i from 1 to (count _selected)
            set end of msgId to id of item i of _selected
        end repeat
        return msgId
	]])
	local next = next
	if not next(messageIds) then
		return nil
	else
		return messageIds
	end
end

function obj.getText()
	osascript.applescript([[tell app "LaunchBar" to perform action "Mail: Get Text"]])
end

function obj.pane1(appObj)
	-- focus on mailbox list
	local e = ui.getUIElement(appObj, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}})
	e:setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
	-- focus on messages list
	local msgsList = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXTable", 1}}
	local e = ui.getUIElement(appObj, msgsList)
	e:setAttributeValue("AXFocused", true)
	if not getSelectedMessages() then
		for _ = 1, 2 do
			eventtap.keyStroke({}, "down")
		end
	end
end

function obj.pane3(appObj)
	-- focus on a specific message
	-- get message's body position
	local msgArea = {
		{"AXWindow", 1},
		{"AXSplitGroup", 1},
		{"AXSplitGroup", 1},
		{"AXScrollArea", 2},
		{"AXGroup", 1},
		{"AXScrollArea", 1},
		{"AXGroup", 1}
	}
	local e = ui.getUIElement(appObj, msgArea)
	-- without a mouse click link highlighting would not work
	local pos = e:attributeValue("AXPosition")
	local point = geometry.point({pos.x + 10, pos.y + 10})
	eventtap.leftClick(point)
end

return obj
