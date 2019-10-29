
local m = {}

m.id = 'com.apple.FaceTime'

-- FaceTime.buttons = function (btn)
-- 	hs.osascript.applescript(string.format([[
-- 		tell application "System Events"
-- 			tell process "FaceTime"
-- 				tell window 1
-- 					-- SideBar, Mute, End, Mute Video, Button (button 6 (screenshot))
-- 					click button "%s"
-- 				end tell
-- 			end tell
-- 		end tell]], btn))
-- end

-- appScripts['com.apple.FaceTime'] = {
-- 	-- SideBar, Mute, End, Mute Video, Button (button 6 (screenshot))
-- 	-- function FaceTime.sidebar()
-- 	-- 	faceTimeButtons("SideBar")
-- 	-- end

-- 	-- function FaceTime.mute()
-- 	-- 	faceTimeButtons("Mute")
-- 	-- end
--   }

return m
