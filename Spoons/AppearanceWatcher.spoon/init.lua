local task = require("hs.task")
local settings = require("hs.settings")
local pathwatcher = require("hs.pathwatcher")
local Host = require("hs.host")

local obj = {}

local appearanceWatcherActiveKey = settingKeys.appearanceWatcherActive
local cachedInterfaceStyleKey = settingKeys.cachedInterfaceStyle

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

obj.pathwatcher = nil

local function setStyle()
  local currentSystemStyle = Host.interfaceStyle() or "Light"
  local cachedStyle = settings.get(cachedInterfaceStyleKey)
  if currentSystemStyle ~= cachedStyle then
    local msg = string.format("AppearanceWatcher: detected a system style change, from %s to %s", cachedStyle, currentSystemStyle)
    print(msg)
    if settings.get(appearanceWatcherActiveKey) == false then
      return
    end
    settings.set(cachedInterfaceStyleKey, currentSystemStyle)
    task.new(
      script_path() .. "/appearance.sh",
      function(exitCode, stdOut, stdErr)
        if exitCode > 0 then
          msg = string.format([[AppearanceWatcher: appearance.sh exited with non-zero exit code (%s). stdout: %s, stderr: %s]], exitCode, stdOut, stdErr)
          print(msg)
        end
      end,
      {currentSystemStyle:lower()}
    ):start()
  end
end

function obj:init()
  self.pathwatcher =
    pathwatcher.new(
    os.getenv("HOME") .. "/Library/Preferences/.GlobalPreferences.plist",
    function()
      setStyle()
    end
  )
  setStyle()
  obj.pathwatcher:start()
end

return obj
