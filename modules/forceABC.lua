local keycodes = require('hs.keycodes')
local menubar = require("hs.menubar")
local settings = require("hs.settings")

local mod = {}

mod.menuBarIcon = nil

-- BEGIN HEBREW --
function mod.currentState()
    return settings.get("forceABC")
end

function mod.keepState(appObj)
    if mod.currentState() == "enabled" then
        if appObj and appObj:bundleID() == "desktop.WhatsApp" then
            keycodes.setLayout("Hebrew")
        else
            keycodes.setLayout("ABC")
        end
        mod.menuBarIcon:removeFromMenuBar()
    else
        mod.menuBarIcon:returnToMenuBar()
    end
end

function mod.toggleState()
    if mod.currentState() == "enabled" then
        settings.set("forceABC", "disabled")
    elseif mod.currentState() == "disabled" then
        settings.set("forceABC", "enabled")
    end
    mod.keepState()
end

function mod.init()
    mod.menuBarIcon = menubar.new():setTitle('✓HEB'):removeFromMenuBar()
    -- initialize if not previously set, default to enabled
    if not mod.currentState() then
        settings.set("forceABC", "enabled")
    end
    mod.keepState()
end

return mod
-- END HEBREW --
