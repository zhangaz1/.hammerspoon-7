local geometry = require("hs.geometry")
local eventtap = require("hs.eventtap")
local timer = require("hs.timer")
local window = require("hs.window")

local mod = {}

function mod.newWindowForFrontApp(hsAppObj, modal)
    local focusedAppId = hsAppObj:bundleID()
    local realFocusedAppId = window.focusedWindow():application():bundleID()
    if focusedAppId == realFocusedAppId then
        eventtap.keyStroke({'cmd', 'alt'}, 'n')
    else
        -- temporarily exit the modal
        modal:exit()
        -- timer.doAfter(0.1, function()
        eventtap.keyStroke({'cmd'}, 'n')
        -- end)
        modal:enter()
    end
end

return mod
