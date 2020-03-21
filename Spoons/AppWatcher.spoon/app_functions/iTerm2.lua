local osascript = require("hs.osascript")

local obj = {}

obj.id = "com.googlecode.iterm2"

function obj.getText()
  osascript.applescript([[
    ignoring application responses
      tell application "LaunchBar" to perform action "iTerm: Get Text"
    end ignoring]])
end

return obj
