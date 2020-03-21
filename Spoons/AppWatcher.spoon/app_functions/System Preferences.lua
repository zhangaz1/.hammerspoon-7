local osascript = require("hs.osascript")

local obj = {}

obj.id = "com.apple.systempreferences"

function obj.allowAnyway()
  osascript.applescript('tell application "System Events" to click button "Allow Anyway" of tab group 1 of window 1 of application process "System Preferences"')
end

function obj.authorizePane()
  osascript.applescript('tell application "System Preferences" to authorize current pane')
end

return obj
