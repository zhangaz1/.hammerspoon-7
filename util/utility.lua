local settings = require("hs.settings")
local host = require("hs.host")
local geometry = require("hs.geometry")
local eventtap = require("hs.eventtap")
local timer = require("hs.timer")
local window = require("hs.window")

local mod = {}

function mod.doubleLeftClick(coords, mods)
    -- requires a table
    local point = geometry.point(coords)
    if mods == nil then mods = {} end

    local clickState = eventtap.event.properties.mouseEventClickState
    eventtap.event.newMouseEvent(eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 1):setFlags(mods):post()
    eventtap.event.newMouseEvent(eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 1):setFlags(mods):post()
    -- timer.usleep(1000)
    timer.doAfter(0.001, function()
        eventtap.event.newMouseEvent(eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 2):setFlags(mods):post()
        eventtap.event.newMouseEvent(eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 2):setFlags(mods):post()
    end)
end

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
