local hs = hs
local hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")
local timer = require("hs.timer")
local pasteboard = require("hs.pasteboard")
local application = require("hs.application")
local ax = require("hs._asm.axuielement")
local keycodes = require("hs.keycodes")

local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

-- Look up in Dictionary
hotkey.bind(hyper, 'L', function()
    eventtap.keyStroke({'cmd'}, 'c')
    timer.doAfter(0.4, function()
        local arg = "dict://"..pasteboard.getContents()
        hs.task.new("/usr/bin/open", nil, { arg }):start()
    end)
end)

-- Move focus to menu bar
hotkey.bind({'cmd', 'shift'}, '1', function()
    ax.systemElementAtPosition({0, 0}):attributeValue('AXParent')[2]:doPress()
end)

hotkey.bind({'alt'}, 'e', function()
    -- BEGIN HEBREW SUPPORT
    keycodes.setLayout("ABC")
    -- END HEBREW SUPPORT
    local menuBar = ax.systemElementAtPosition({0, 0}):attributeValue('AXParent')
    for _, v in ipairs(menuBar) do
        if v:attributeValue("AXTitle") == "Help" then
            v:doPress()
            return
        end
    end
end)

-- Right Click
hotkey.bind(hyper, 'O', function()
    local thisApp = application.frontmostApplication()
    ax.applicationElement(thisApp):focusedUIElement():performAction('AXShowMenu')
end)

-- Switch to English for Emoji & Symbols, and Spotlight
-- BEGIN HEBREW RELATED
eventtap.new(
{eventtap.event.types.keyUp},
function(event)
	local keyName = keycodes.map[event:getKeyCode()]
    if keyName == "space" then
        local eventFlags = event:getFlags()
        if eventFlags:containExactly({"ctrl", "cmd"}) or eventFlags:containExactly({"alt"}) then
            if keycodes.currentLayout() == "ABC" then return end
            keycodes.setLayout("ABC")
		end
	end
end
):start()
-- END HEBREW RELATED
