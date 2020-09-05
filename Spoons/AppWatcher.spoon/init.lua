--- === AppWatcher ===
---
--- an `hs.application.watcher` instance bolstered by `hs.window.filter` to catch and react on activation of "transient"
--- apps, such as Spotlight and the 1Password 7 mini window.
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

local appWatcher = nil
local frontAppBundleID = nil
local windowFilter = nil

local function mainCallback(_, event, appObj)
  local newBundleID = appObj:bundleID()

  if event ~= "FROM_WINDOW_WATCHER" then
    spoon.AppQuitter:update(event, newBundleID)
  end

  if event == Application.watcher.activated or event == "FROM_WINDOW_WATCHER" then
    if newBundleID == frontAppBundleID then
      return
    end
    frontAppBundleID = newBundleID

    spoon.AppSpoonsManager:update(appObj, newBundleID)
    spoon.KeyboardLayoutManager:setInputSource(newBundleID)
  end
end

local function windowFilterCallback(hsWindow, _, event)
  -- second arg is the app's name
  local appObj = hsWindow:application()
  if not appObj then
    return
  end
  local bundleID = appObj:bundleID()
  if event == "windowFocused" or event == "windowCreated" then
    if bundleID == frontAppBundleID then
      return
    end
    mainCallback(nil, "FROM_WINDOW_WATCHER", appObj)
  elseif event == "windowDestroyed" then
    mainCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  end
end

--- AppWatcher.transientApps
--- Variable
--- a table containing apps you consider to be transient and want to be taken into account by the window filter.
--- elements should have the same structure as the `filters` parameter of hs.window.filter `setFilters` method.
obj.transientApps = {
  ["LaunchBar"] = {allowRoles = "AXSystemDialog"},
  ["1Password 7"] = {allowRoles = "AXSystemDialog"},
  ["Spotlight"] = {allowRoles = "AXSystemDialog"},
  ["Contexts"] = false,
  ["Emoji & Symbols"] = true
}

--- AppWatcher:stop()
--- Method
--- Starts the module.
function obj:stop()
  windowFilter:unsubscribe()
  appWatcher:stop()
end

--- AppWatcher:start()
--- Method
--- Starts the module.
function obj.start()
  local allowedWindowFilterEvents = {
    Window.filter.windowCreated,
    Window.filter.windowDestroyed,
    Window.filter.windowFocused
  }
  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  mainCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  appWatcher:start()
  windowFilter:setFilters(obj.transientApps):subscribe(allowedWindowFilterEvents, windowFilterCallback)
  local window = Application.frontmostApplication():mainWindow()
  if window then
    windowFilterCallback(window, nil, "windowFocused")
  end
end

function obj:init()
  windowFilter = Window.filter.new(false)
  appWatcher = Application.watcher.new(mainCallback)
end

return obj
