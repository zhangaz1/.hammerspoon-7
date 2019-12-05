local task = require("hs.task")
local settings = require("hs.settings")
local pathwatcher = require("hs.pathwatcher")
local Host = require("hs.host")

local obj = {}

function obj.setStyle()
  local currentSystemStyle = Host.interfaceStyle()
  if not currentSystemStyle then
    currentSystemStyle = "Light"
  end

  local cachedStyle = settings.get("HSAppearanceWatcherInterfaceStyle")

  if currentSystemStyle ~= cachedStyle then
    print("detected system interface style change, to => " .. currentSystemStyle)
    print("cached system interface style is currently => " .. (cachedStyle or "NOT_CACHED"))

    local interfaceParameter
    if currentSystemStyle == "Dark" then
      interfaceParameter = "dark"
    elseif currentSystemStyle == "Light" then
      interfaceParameter = "light"
    end

    settings.set("HSAppearanceWatcherInterfaceStyle", currentSystemStyle)

    print("cached system interface style change is now => " .. (settings.get("HSAppearanceWatcherInterfaceStyle") or "NOT_CACHED"))

    task.new(
      "modules/appearance.sh",
      function(exitCode, stdOut, stdErr)
        print(exitCode, stdOut, stdErr)
      end,
      {interfaceParameter}
    ):start()
  end
end

function obj.init()
  obj.setStyle()
  appearanceWatcher = pathwatcher.new(os.getenv("HOME") .. "/Library/Preferences/.GlobalPreferences.plist", obj.setStyle)
  appearanceWatcher:start()
end

return obj
