local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local pasteboard = require("hs.pasteboard")
local geometry = require("hs.geometry")
local image = require("hs.image")
local urlevent = require("hs.urlevent")
local ax = require("hs._asm.axuielement")
local ui = require("util.ui")
local chooser = require("hs.chooser")

local m = {}
m.id = "com.apple.mail"
m.thisApp = nil
m.modal = hotkey.modal.new()

local function getSelectedMessages()
	local _, messageIds, _ =
		osascript.applescript(
		[[
        set msgId to {}
        tell application "Mail" to set _selected to selection
        repeat with i from 1 to (count _selected)
            set end of msgId to id of item i of _selected
        end repeat
        return msgId
    ]]
	)
	local next = next
	if not next(messageIds) then
		return nil
	else
		return messageIds
	end
end

local function pane1()
	-- focus on mailbox list
	local e = ui.getUIElement(m.thisApp, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}})
	e:setAttributeValue("AXFocused", true)
end

local function pane2()
	-- focus on messages list
	local msgsList = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXTable", 1}}
	local e = ui.getUIElement(m.thisApp, msgsList)
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
	local e = ui.getUIElement(m.thisApp, msgArea)
	-- without a mouse click link highlighting would not work
	local pos = e:attributeValue("AXPosition")
	local point = geometry.point({pos.x + 10, pos.y + 10})
	eventtap.leftClick(point)
end

local function copySenderAddress()
	local _, b, _ =
		osascript.applescript(
		[[tell application "Mail"
		set sendersList to {}
		set theMessages to the selected messages of message viewer 0
		repeat with aMessage in theMessages
			set end of sendersList to extract address from (sender of aMessage)
		end repeat
		end tell
		return sendersList]]
	)
	pasteboard.setContents(table.concat(b, "\n"))
end

local function mailGetLinks()
	local output = {}
	local window = ax.windowElement(m.thisApp:focusedWindow())
	local e =
		ui.getUIElement(
		window,
		({
			{"AXSplitGroup", 1},
			{"AXSplitGroup", 1},
			{"AXScrollArea", 2},
			{"AXGroup", 1},
			{"AXScrollArea", 1},
			{"AXGroup", 1},
			{"AXGroup", 1},
			{"AXScrollArea", 1},
			{"AXWebArea", 1}
		})
	)
	local links = e:attributeValue("AXLinkUIElements")
	if not next(links) then
		table.insert(output, {["text"] = "Message Contains No Links"})
	else
		for _, v in ipairs(links) do
			local title = v:attributeValue("AXTitle")
			local url = v:attributeValue("AXURL")
			table.insert(
				output,
				{
					["text"] = title or url,
					["subText"] = url,
					["url"] = url,
					["image"] = image.imageFromPath(
						"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/InternetLocation.icns"
					)
				}
			)
		end
	end
	local function openURL(choice)
		if choice then
			urlevent.openURL(choice.url)
		end
	end
	local rows
	for i, _ in ipairs(output) do
		rows = i
	end
	chooser.new(openURL):choices(output):rows(rows):show()
end

m.modal:bind(
	{"alt"},
	"1",
	function()
		pane1()
	end
)
m.modal:bind(
	{"alt"},
	"2",
	function()
		pane2()
	end
)
m.modal:bind(
	{"alt"},
	"3",
	function()
		pane3()
	end
)
m.modal:bind(
	{"alt"},
	"o",
	function()
		mailGetLinks()
	end
)

m.appScripts = {
	{title = "Copy Sender Address", func = function()
			copySenderAddress()
		end}
}

return m
