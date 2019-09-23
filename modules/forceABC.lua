local keycodes = require('hs.keycodes')
local menubar = require("hs.menubar")
local settings = require("hs.settings")

local mod = {}

local menuBarIcon;

function mod.keepState()
    local currentState = settings.get("forceABC")
    if currentState == "enabled" then
        keycodes.setLayout("ABC")
    end
end

function mod.toggleState()
    local currentState = settings.get("forceABC")
    -- toggling  enabled -> disabled
    if currentState == "enabled" then
        settings.set("forceABC", "disabled")
        menuBarIcon:returnToMenuBar()
    -- toggling disabled -> enabled
    elseif currentState == "disabled" then
        settings.set("forceABC", "enabled")
        menuBarIcon:removeFromMenuBar()
    end
    print("NOW: ==> " .. settings.get("forceABC"))
    if currentState == "enabled" then
        keycodes.setLayout("ABC")
    end
end

function mod.init()
    menuBarIcon = menubar:new():setTitle("✓HEB"):removeFromMenuBar()
    local currentState = settings.get("forceABC")
    -- initialize if not previously set
    if not currentState then
        settings.set("forceABC", "enabled")
    end

    if currentState == "enabled" then
        keycodes.setLayout("ABC")
    else
        menuBarIcon:returnToMenuBar()
    end
end

return mod
