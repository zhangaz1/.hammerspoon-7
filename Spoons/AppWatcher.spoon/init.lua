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

local transientApps = {
  ["LaunchBar"] = {allowRoles = "AXSystemDialog"},
  ["1Password 7"] = {allowRoles = "AXSystemDialog"},
  ["Spotlight"] = {allowRoles = "AXSystemDialog"},
  ["Contexts"] = false,
  ["Emoji & Symbols"] = true
}

local allowedWindowFilterEvents = {
  Window.filter.windowCreated,
  Window.filter.windowDestroyed,
  Window.filter.windowFocused
}

local function appWatcherCallback(_, event, appObj)
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
    appWatcherCallback(nil, "FROM_WINDOW_WATCHER", appObj)
  elseif event == "windowDestroyed" then
    appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  end
end

function obj.start()
  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  appWatcher:start()
  windowFilter:setFilters(transientApps):subscribe(allowedWindowFilterEvents, windowFilterCallback)
  local window = Application.frontmostApplication():mainWindow()
  if window then
    windowFilterCallback(window, nil, "windowFocused")
  end
end

function obj.init()
  windowFilter = Window.filter.new(false)
  appWatcher = Application.watcher.new(appWatcherCallback)
end

return obj

-- local function appWatcherCallback(_, event, appObj)
--   local bundleID = appObj:bundleID()
--   if event ~= "FROM_WINDOW_WATCHER" then
--     spoon.AppQuitter:update(event, bundleID)
--   end
--   if event == Application.watcher.activated or event == "FROM_WINDOW_WATCHER" then
--     if bundleID == obj.frontAppBundleID then
--       return
--     end
--     obj.frontApp = appObj
--     obj.frontAppBundleID = bundleID
--     if bundleID == "com.apple.Safari" then
--       safariAddObserver(appObj)
--     else
--       if obj.safariObserver then
--         obj.safariObserver:stop()
--       end
--       setInputSource(bundleID) -- set input source
--     end
--     enterModalForActiveApp() -- enter modal
--     if event ~= "FROM_WINDOW_WATCHER" then
--       obj.lastNonTransientApp = appObj
--     end
--   end

-- end

-- local function windowFilterCallback(hsWindow, _, event) -- second arg is the app's name
--   local appObj = hsWindow:application()
--   if not appObj then
--     return
--   end
--   local bundleID = appObj:bundleID()
--   if event == "windowFocused" or event == "windowCreated" then
--     if bundleID == obj.frontAppBundleID then
--       return
--     end
--     appWatcherCallback(nil, "FROM_WINDOW_WATCHER", appObj)
--   elseif event == "windowDestroyed" then
--     appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
--   end
-- end

-- local function enterModalForActiveApp()
--   for id, modal in pairs(modals) do
--     if id == frontAppBundleID then
--       modal:enter()
--     else
--       modal:exit()
--     end
--   end
-- end
