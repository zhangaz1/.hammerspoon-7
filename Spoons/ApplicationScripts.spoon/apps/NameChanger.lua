local osascript = require("hs.osascript")

local obj = {}

obj.id = "com.mrrsoftware.NameChanger"

function obj.changeRenameType()
    osascript.applescript([[tell application "System Events" to click (pop up button 1 whose description of it = "Type of Rename") of window 1 of application process "NameChanger"]])
end

return obj
