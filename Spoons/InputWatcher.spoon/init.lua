local EventTap = require("hs.eventtap")
local KeyCodes = require("hs.keycodes")
local Timer = require("hs.timer")

local obj = {}

obj.__index = obj
obj.name = "InputWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.watcher = nil

local function getFrontApp()
  return spoon.AppWatcher.frontApp
end

local function getFrontAppID()
  return spoon.AppWatcher.frontAppBundleID
end

local function watcherCallback(event)
  local keyCode = event:getKeyCode()
  local eventFlags = event:getFlags()
  -- local currentLayout = KeyCodes.currentLayout()

  -- global
  -- switch to english for Spotlight
  -- switch to english for Emoji & Symbols
  if keyCode == KeyCodes.map.space then
    if eventFlags:containExactly({"ctrl", "cmd"}) or eventFlags:containExactly({"alt"}) then
      -- if currentLayout == "ABC" then
      --   return
      -- end
      KeyCodes.setLayout("ABC")
    end
  end

  -- whatsapp
  if getFrontAppID() == "desktop.WhatsApp" then
    -- keycode 3 ==> f/כ
    if (keyCode == 3) and eventFlags:containExactly({"cmd"}) then
      KeyCodes.setLayout("ABC")
    end
    if (keyCode == KeyCodes.map["return"] or keyCode == KeyCodes.map.tab) and eventFlags:containExactly({}) then
      KeyCodes.setLayout("Hebrew")
    end
  end

  if getFrontAppID() == "com.apple.Safari" then
    if keyCode == KeyCodes.map["return"] and eventFlags:containExactly({}) then
      local safariSpoon = spoon.ApplicationScripts.appEnvs["com.apple.Safari"]
      local safari = getFrontApp()
      safariSpoon.moveFocusToMainAreaAfterOpeningLocation(safari)
    end
    -- t/l
    if (keyCode == 17 or keyCode == 37) and eventFlags:containExactly({"cmd"}) then
        KeyCodes.setLayout("ABC")
    end
  end

end

function obj:init()
  self.watcher = EventTap.new({EventTap.event.types.keyUp}, watcherCallback)
end

function obj:stop()
  self.watcher:stop()
end

function obj:start()
  self.watcher:start()
end

return obj
