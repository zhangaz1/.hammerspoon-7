local hotkey = require("hs.hotkey")

local m = {}
m.id = "com.apple.Stickies"
m.thisApp = nil
m.modal = hotkey.modal.new()

return m
