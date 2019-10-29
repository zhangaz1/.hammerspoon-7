local task = require("hs.task")
local settings = require("hs.settings")
local pathwatcher = require("hs.pathwatcher")
local plist = require("hs.plist")

local obj = {}

local plistFile = os.getenv("HOME") .. "/Library/Preferences/.GlobalPreferences.plist"
obj.scriptPath = "modules/appearance.sh"

function obj.currentStyle()
  return plist.read(plistFile).AppleInterfaceStyle
end

function obj.setStyle()
  local currentStyle = obj.currentStyle()
  local cachedStyle = settings.get("HSAppearanceWatcherInterfaceStyle")

  if not currentStyle then
    currentStyle = "Light"
  end

  if currentStyle ~= cachedStyle then
    local arg
    if currentStyle == "Dark" then
      arg = "dark"
    elseif currentStyle == "Light" then
      arg = "light"
    end

    task.new(
      obj.scriptPath,
      function(exitCode, stdOut, stdErr)
        print(exitCode, stdOut, stdErr)
        settings.set("HSAppearanceWatcherInterfaceStyle", currentStyle)
        print("Current style is: "..currentStyle)
        if not cachedStyle then
          cachedStyle = currentStyle
        end
        print("Cached style is: "..cachedStyle)
      end,
      {arg}
    ):start()
  end
end

function obj.init()
  obj.setStyle()
  appearanceWatcher = pathwatcher.new(plistFile, obj.setStyle)
  appearanceWatcher:start()
end

return obj
