local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")

local obj = {}
obj.id = "com.googlecode.iterm2"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

local function getText()
  osascript.applescript([[
    ignoring application responses
      tell application "LaunchBar" to perform action "iTerm: Get Text"
    end ignoring]])
end

obj.modal:bind({"alt"}, "f", getText)

return obj
