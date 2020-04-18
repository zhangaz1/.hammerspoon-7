local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local pasteboard = require("hs.pasteboard")
local geometry = require("hs.geometry")
local ax = require("hs._asm.axuielement")

local ui = require("rb.ui")
local fuzzyChooser = require("rb.fuzzychooser")
local Util = require("rb.util")

local obj = {}

obj.id = "com.apple.mail"

local function chooserCallback(choice)
	os.execute(string.format([["/usr/bin/open" "%s"]], choice.url))
end

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

function obj.copySenderAddress()
	local _, b, _ = osascript.applescript([[tell application "Mail"
		set sendersList to {}
		set theMessages to the selected messages of message viewer 0
		repeat with aMessage in theMessages
			set end of sendersList to extract address from (sender of aMessage)
		end repeat
		end tell
		return sendersList]])
	pasteboard.setContents(table.concat(b, "\n"))
end

function obj.getMessageLinks(appObj)
	local window = ax.windowElement(appObj:focusedWindow())
	-- when viewed in the main app OR when viewed in a standalone container
	local messageWindow = ui.getUIElement(window, ({{"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}})) or ui.getUIElement(window, ({{"AXScrollArea", 1}}))
	local messageContainers = messageWindow:attributeValue("AXChildren")
	local choices = {}
	for _, messageContainer in ipairs(messageContainers) do
		if messageContainer:attributeValue("AXRole") == "AXGroup" then
			local webArea =
				ui.getUIElement(
				messageContainer,
				{
					{"AXScrollArea", 1},
					{"AXGroup", 1},
					{"AXGroup", 1},
					{"AXScrollArea", 1},
					{"AXWebArea", 1}
				}
			)
			local links = webArea:attributeValue("AXLinkUIElements")
			for _, v in ipairs(links) do
				local title = v:attributeValue("AXTitle")
				local url = v:attributeValue("AXURL")
				table.insert(
					choices,
					{
						url = url,
						text = title or url,
						subText = url
					}
				)
			end
		end
	end
	if Util.tableCount(choices) == 0 then
		table.insert(
			choices,
			{
				text = "No Links"
			}
		)
	end
	fuzzyChooser:start(chooserCallback, choices, {"text", "subText"})
end

return obj
