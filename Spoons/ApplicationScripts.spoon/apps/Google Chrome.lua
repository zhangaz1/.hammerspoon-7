local osascript = require("hs.osascript")

local obj = {}

obj.id = "com.google.Chrome"

function obj.closeOtherTabs()
  osascript.applescript([[
    tell application "Google Chrome"
    tell window 1
      set activeID to the id of its active tab
      set theTabs to every tab
      repeat with i from 1 to count theTabs
        tell item i of theTabs
          if its id is not equal to activeID then
            close
          end if
        end tell
      end repeat
    end tell
  end tell
  ]])
end

return obj
