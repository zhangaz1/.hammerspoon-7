local EventTap = require("hs.eventtap")
local Window = require("hs.window")

local obj = {}

function obj.perform(keyBinding, app, modal, conditionalFunction, successFunction)
    if (app:bundleID() == Window.focusedWindow():application():bundleID()) then
        local perform = true
        if conditionalFunction ~= nil then
            if not conditionalFunction() then
                perform = false
            end
        end
        if perform then
            successFunction()
        end
    else
        modal:exit()
        EventTap.keyStroke(table.unpack(keyBinding))
        modal:enter()
    end
end

return obj
