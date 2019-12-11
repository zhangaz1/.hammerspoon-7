local osascript = require('hs.osascript')

local m = {}
m.id = 'com.apple.systempreferences'

m.appScripts = {
    { title = 'Authorize Current Pane', func = function() osascript.applescript('tell application "System Preferences" to authorize current pane') end },
    { title = 'Allow Extension', func = function() osascript.applescript('tell application "System Events" to click button 3 of tab group 1 of window 1 of application process "System Preferences"') end },
}

return m
