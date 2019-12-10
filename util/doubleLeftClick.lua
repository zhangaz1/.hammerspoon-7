local Geometry = require("hs.geometry")
local Eventtap = require("hs.eventtap")
local Timer = require("hs.timer")

local mod = {}

function mod.start(coords, mods)
    -- requires a table
    local point = Geometry.point(coords)
    if mods == nil then mods = {} end
    local clickState = Eventtap.event.properties.mouseEventClickState
    Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 1):setFlags(mods):post()
    Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 1):setFlags(mods):post()
    -- timer.usleep(1000)
    Timer.doAfter(0.1, function()
        Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 2):setFlags(mods):post()
        Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 2):setFlags(mods):post()
    end)
end

return mod
