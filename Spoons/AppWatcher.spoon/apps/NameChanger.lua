local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")

local m = {}

m.id = "com.mrrsoftware.NameChanger"
m.thisApp = nil
m.modal = hotkey.modal.new()

local function changeRenameType()
    osascript.applescript([[tell application "System Events" to click (pop up button 1 whose description of it = "Type of Rename") of window 1 of application process "NameChanger"]])
end

m.modal:bind(
    {"cmd"},
    "down",
    function()
        changeRenameType()
    end
)
return m
