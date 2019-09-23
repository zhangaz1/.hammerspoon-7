local osascript = require('hs.osascript')
local eventtap = require('hs.eventtap')

local m = {}

m.id = 'com.flexibits.cardhop.mac'

local function miniOptions()
	osascript.applescript([[tell application "System Events"
		tell process "Cardhop"
		tell window "Cardhop"
		set _btns to every button
		repeat with i from 1 to count of _btns
			set _btn to item i of _btns
			tell _btn
			if description = "options" then
				ignoring application responses
				return click _btn
			end ignoring
		end if
	end tell
	end repeat
	end tell
	end tell
	end tell]])
end

m.appScripts = {
	{ title = "Add Field", func = function() eventtap.keyStroke({'cmd', 'alt'}, 'f') end },
	{ title = "Float on Top", func = function() eventtap.keyStroke({'ctrl', 'cmd'}, 'a') end },
	{ title = "Mini Options", func = function() miniOptions() end }
}

return m
