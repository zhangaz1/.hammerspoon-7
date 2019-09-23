local hotkey = require('hs.hotkey')
local console = require('hs.console')

local m = {}
m.id = 'org.hammerspoon.Hammerspoon'
m.modal = hotkey.modal.new()

m.modal:bind({'cmd'}, 'k', function() console.clearConsole() end)
m.modal:bind({'cmd'}, 'r', function() hs.reload() end)

return m
