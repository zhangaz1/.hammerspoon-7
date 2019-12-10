local eventtap = require("hs.eventtap")
local Window = require("hs.window")

local mod = {}

function mod.perform(keyBinding, HSModal, conditionalFunction, successFunction) -- HSAppObj
    if conditionalFunction() then --and (HSAppObj:bundleID() == Window.focusedWindow():application():bundleID()) then
        successFunction()
    else
        HSModal:exit()
        eventtap.keyStroke(table.unpack(keyBinding))
        HSModal:enter()
    end
end

return mod
