local EventTap = require("hs.eventtap")
local KeyCodes = require("hs.keycodes")
local Settings = require("hs.settings")

local obj = {}

local spoon = spoon

obj.__index = obj
obj.name = "InputWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.watcher = nil

local function getFrontApp()
  -- return hs.application.frontmostApplication()
  return spoon.AppWatcher.frontApp
end

local function getFrontAppID()
  return spoon.AppWatcher.frontAppBundleID
  -- return getFrontApp():bundleID()
end

local function getAppEnv(app)
  return spoon.AppWatcher.appFunctions[app]
end

local function watcherCallback(event)
  local keyCode = event:getKeyCode()
  local eventFlags = event:getFlags()

  -- global
  -- switch to english for Spotlight, Emoji & Symbols
  -- if keyCode == KeyCodes.map.space then
  --   if eventFlags:containExactly({"ctrl", "cmd"}) or eventFlags:containExactly({"alt"}) then
  --     KeyCodes.setLayout("ABC")
  --   end
  -- end

  -- whatsapp
  -- keycode 3 ==> f/כ
  if (keyCode == 3) and eventFlags:containExactly({"cmd"}) then
    if getFrontAppID() == "desktop.WhatsApp" then
      KeyCodes.setLayout("ABC")
    end
  end

  if keyCode == KeyCodes.map.tab and eventFlags:containExactly({}) then
    if getFrontAppID() == "desktop.WhatsApp" then
      KeyCodes.setLayout("Hebrew")
    end
  end

  if keyCode == KeyCodes.map["return"] and eventFlags:containExactly({}) then
    if getFrontAppID() == "com.apple.Safari" then
      local safariEnv = getAppEnv("com.apple.Safari")
      local safariAppObj = getFrontApp()
      safariEnv.inputWatcherInvokedMoveFocusToMainAreaAfterOpeningLocation(safariAppObj)
    end
  end
  -- t/l
  if (keyCode == 17 or keyCode == 37) and eventFlags:containExactly({"cmd"}) then
    if getFrontAppID() == "com.apple.Safari" then
      KeyCodes.setLayout("ABC")
    end
  end
  -- local shouldDeleteEvent = false
  -- local eventsToPost = {EventTap.event.types.keyUp}
  -- return shouldDeleteEvent, eventsToPost
end

function obj:init()
  self.watcher = EventTap.new({EventTap.event.types.keyDown}, watcherCallback)
  if Settings.get("InputWatcherWasActive") then
    self.watcher:start()
  end
end

function obj:toggle()
  if obj.watcher then
    if obj.watcher:isEnabled() then
      obj.watcher:stop()
      Settings.set("InputWatcherWasActive", false)
    else
      obj.watcher:start()
      Settings.set("InputWatcherWasActive", true)
    end
  end
end

return obj
