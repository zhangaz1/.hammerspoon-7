local task = require("hs.task")
local settings = require("hs.settings")
local pathwatcher = require("hs.pathwatcher")
local Host = require("hs.host")

local obj = {}

obj.__index = obj
obj.name = "AppearanceWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.spoonPath = script_path()
obj.pathwatcher = nil

function obj:init()
  self.pathwatcher =
    pathwatcher.new(
    os.getenv("HOME") .. "/Library/Preferences/.GlobalPreferences.plist",
    function()
      obj:setStyle()
    end
  )
end

function obj:setStyle()
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
    task.new(
      self.spoonPath .. "/appearance.sh",
      function(exitCode, stdOut, stdErr)
        print(exitCode, stdOut, stdErr)
      end,
      {interfaceParameter}
    ):start()
  end
end

function obj:start()
  obj:setStyle()
  obj.pathwatcher:start()
end

return obj
