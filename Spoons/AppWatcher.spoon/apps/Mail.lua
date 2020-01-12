local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local pasteboard = require("hs.pasteboard")
local geometry = require("hs.geometry")
local image = require("hs.image")

local ax = require("hs._asm.axuielement")

local ui = require("rb.ui")
local GlobalChooser = require("rb.fuzzychooser")

local obj = {}
obj.id = "com.apple.mail"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

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

local function pane1()
	-- focus on mailbox list
	local e = ui.getUIElement(obj.thisApp, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}})
	e:setAttributeValue("AXFocused", true)
end

local function pane2()
	-- focus on messages list
	local msgsList = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXTable", 1}}
	local e = ui.getUIElement(obj.thisApp, msgsList)
	e:setAttributeValue("AXFocused", true)
	if not getSelectedMessages() then
		for _ = 1, 2 do
			eventtap.keyStroke({}, "down")
		end
	end
end

local function pane3()
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
	local e = ui.getUIElement(obj.thisApp, msgArea)
	-- without a mouse click link highlighting would not work
	local pos = e:attributeValue("AXPosition")
	local point = geometry.point({pos.x + 10, pos.y + 10})
	eventtap.leftClick(point)
end

local function copySenderAddress()
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

local function getMessageLinks()
	local window = ax.windowElement(obj.thisApp:focusedWindow())
	-- when viewed in the main app OR when viewed in a standalone container
	local messageWindow = ui.getUIElement(window, ({{"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}})) or ui.getUIElement(window, ({{"AXScrollArea", 1}}))
	local webArea =
		ui.getUIElement(
		messageWindow,
		{
			{"AXGroup", 1},
			{"AXScrollArea", 1},
			{"AXGroup", 1},
			{"AXGroup", 1},
			{"AXScrollArea", 1},
			{"AXWebArea", 1}
		}
	)
	local links = webArea:attributeValue("AXLinkUIElements")
	local choices = {}
	if not next(links) then
		table.insert(choices, {["text"] = "Message Contains No Links"})
	else
		for _, v in ipairs(links) do
			local title = v:attributeValue("AXTitle")
			local url = v:attributeValue("AXURL")
			table.insert(
				choices,
				{
					text = title or url,
					subText = url,
					url = url,
					image = image.imageFromPath("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/InternetLocation.icns")
				}
			)
		end
	end
	GlobalChooser:start(chooserCallback, choices, {"text", "subText"})
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
obj.modal:bind(
	{"alt"},
	"3",
	function()
		pane3()
	end
)
obj.modal:bind(
	{"alt"},
	"o",
	function()
		getMessageLinks()
	end
)

obj.appScripts = {
	{
		title = "Copy Sender Address",
		func = copySenderAddress
	}
}

return obj
