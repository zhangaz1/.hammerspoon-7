local Application = require("hs.application")
local Window = require("hs.window")

local spoon = spoon

local obj = {}

obj.__index = obj
obj.name = "AppWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.appWatcher = nil

-- important global variables, shared across HS env
obj.frontApp = nil
obj.frontAppBundleID = nil
obj.activeModal = nil
obj.applicationModals = nil

local allowedEvents = {
  Window.filter.windowFocused,
  Window.filter.windowCreated
}
local additionalApps = {"LaunchBar", "1Password 7", "Contexts"}

-- app watcher callBack
-- local function appWatcherCallback(_, event, appObj)
--   if (event == Application.watcher.activated) then
--     obj.frontApp = appObj
--     obj.frontAppBundleID = appObj:bundleID()
--     spoon.InputSourceGuard:start(appObj)
--     for id, modal in pairs(obj.applicationModals) do
--       if id == obj.frontAppBundleID then
--         obj.activeModal = modal
--         modal:enter()
--       else
--         modal:exit()
--       end
--     end
--   end
-- end

-- function obj:start()
--   -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
--   obj.applicationModals = spoon.Hotkeys.modals
--   obj.frontApp = Application.frontmostApplication()
--   appWatcherCallback(nil, Application.watcher.activated, obj.frontApp)
--   self.appWatcher:start()
-- end

-- function obj:init()
--   self.appWatcher = Application.watcher.new(appWatcherCallback)
-- end

-- app watcher callback
local function windowFilterCallback(hsWindow, appNameString, eventName)
  if eventName == "windowCreated" or eventName == "windowFocused" then
    local appObj = hsWindow:application()
    obj.frontApp = appObj
    obj.frontAppBundleID = appObj:bundleID()
    spoon.InputSourceGuard:start(appObj)
    for id, modal in pairs(obj.applicationModals) do
      if id == obj.frontAppBundleID then
        obj.activeModal = modal
        modal:enter()
      else
        modal:exit()
      end
    end
  end
end

function obj:start()
  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  obj.applicationModals = spoon.Hotkeys.modals
  obj.frontApp = Application.frontmostApplication()
  windowFilterCallback(obj.frontApp:focusedWindow(), "windowFocused", obj.frontApp)
  self.windowFilter:subscribe(allowedEvents, windowFilterCallback):resume()
end

function obj:init()
  self.windowFilter = Window.filter.new()
end

return obj
