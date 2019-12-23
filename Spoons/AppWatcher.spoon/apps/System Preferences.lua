local osascript = require('hs.osascript')

local m = {}
m.id = 'com.apple.systempreferences'

local function allowAnyway()
  osascript.applescript(
    'tell application "System Events" to click button "Allow Anyway" of tab group 1 of window 1 of application process "System Preferences"')
end

local function authorizePane() osascript.applescript('tell application "System Preferences" to authorize current pane') end

m.appScripts = {
  {title = 'Authorize Pane', func = authorizePane}, {title = 'Allow', func = allowAnyway}
}

return m
