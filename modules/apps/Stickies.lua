local hotkey = require('hs.hotkey')
local ax = require("hs._asm.axuielement")
local eventtap = require("hs.eventtap")

local m = {}
m.id = 'com.apple.Stickies'
m.thisApp = nil
m.modal = hotkey.modal.new()

return m
