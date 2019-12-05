local eventtap = require("hs.eventtap")

local mod = {}

function mod.perform(keyBinding, HSModal, conditionalFunction, successFunction)
    if conditionalFunction() then
        successFunction()
    else
        HSModal:exit()
        eventtap.keyStroke(table.unpack(keyBinding))
        HSModal:enter()
    end
end

return mod
