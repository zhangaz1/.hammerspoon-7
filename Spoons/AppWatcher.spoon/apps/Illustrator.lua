local hotkey = require('hs.hotkey')
local eventtap = require('hs.eventtap')

local m = {}
m.id = 'com.adobe.illustrator'
m.modal = hotkey.modal.new()

m.modal:bind({'ctrl'}, 'tab', function() eventtap.keyStroke({'cmd'}, '`') end)
m.modal:bind({'ctrl', 'shift'}, 'tab', function() eventtap.keyStroke({'cmd', 'shift'}, '`') end)

return m
