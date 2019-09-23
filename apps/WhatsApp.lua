local hotkey = require('hs.hotkey')
local geometry = require('hs.geometry')
local eventtap = require('hs.eventtap')

local m = {}
m.id = 'desktop.WhatsApp'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function whatsAppMouseScripts(requestedAction)
    local x;
    local y;
    local frame = m.thisApp:focusedWindow():frame()
    if requestedAction == 'AttachFile' then
        x =  (frame.x + frame.w - 85)
        y =  (frame.y + 30)
    else
        x = (frame.center.x + 80)
        y = (frame.center.y + 30)
    end
    local p = geometry.point({x, y})
    return eventtap.leftClick(p)
end

local function insertGif()
    eventtap.keyStroke({'shift'}, 'tab')
    eventtap.keyStroke({}, 'return')
    eventtap.keyStroke({}, 'tab')
end

m.appScripts = {
    { title = "Insert GIF", func = function() insertGif() end },
    { title =  "Attach File", func = function() whatsAppMouseScripts('AttachFile') end },
    { title =  "Use Here", func = function() whatsAppMouseScripts('Use Here') end }
}

return m
