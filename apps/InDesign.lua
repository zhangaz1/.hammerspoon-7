local hotkey = require('hs.hotkey')
local eventtap = require('hs.eventtap')

local m = {}
m.id = 'com.adobe.InDesign'
m.modal = hotkey.modal.new()

m.modal:bind({'ctrl'}, 'tab', function() eventtap.keyStroke({'cmd'}, '`') end)
m.modal:bind({'shift', 'ctrl'}, 'tab', function() eventtap.keyStroke({'shift', 'cmd'}, '`') end)

return m
