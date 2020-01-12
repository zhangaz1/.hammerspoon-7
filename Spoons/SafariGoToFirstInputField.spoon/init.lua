local AppleScript = require("hs.osascript").applescript

local obj = {}

obj.__index = obj
obj.name = "SafariGoToFirstInputField"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local jsFile = script_path() .. "/goToFirstInputField.js"

function obj:start()
  local script = [[
    set theFile to (POSIX file "%s" as alias)
    set theScript to read theFile as string
    tell application "Safari"
	  tell (window 1 whose visible of it = true)
		  tell (tab 1 whose visible of it = true)
			  return do JavaScript theScript
		  end tell
	  end tell
    end tell
  ]]
  script = string.format(script, jsFile)
  AppleScript(script)
end

return obj
