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
        hs.execute(string.format([["/usr/bin/open" "%s"]], arg))
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
