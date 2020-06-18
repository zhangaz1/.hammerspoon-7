local Application = require("hs.application")
local Window = require("hs.window")
local FNUtils = require("hs.fnutils")
local Settings = require("hs.settings")
local Keycodes = require("hs.keycodes")
local URLEvent = require("hs.urlevent")
local Hotkey = require("hs.hotkey")

local settingKeys = settingKeys

local obj = {}

obj.__index = obj
obj.name = "AppWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.appquitter = dofile(script_path() .. "/appquitter.lua")

local appsLastActiveKeyboardLayoutsKey = settingKeys.appsLastActiveKeyboardLayouts
local safariKeyboardLayoutsPerTabKey = settingKeys.safariKeyboardLayoutsPerTab

obj.windowFilter = nil

-- important global variables, shared across HS env
obj.frontApp = nil
obj.frontAppBundleID = nil
obj.activeModal = nil

obj.appFunctions = {}
obj.appActions = {}

local modals = {}
obj.modals = modals -- for a cheatsheet?

obj.runningApplications = {}
obj.timer = nil

local keyboardLayoutSwitcherExcludedApps = {
  "at.obdev.LaunchBar",
  "com.contextsformac.Contexts"
}

local function setInputSource(bundleid)
  -- need safari override
  local settingsTable = Settings.get(appsLastActiveKeyboardLayoutsKey)
  local appSetting = settingsTable[bundleid]
  -- default to abc if no saved setting
  local newLayout = "ABC"
  if appSetting then
    -- reset back to abc based on timestamp?
    newLayout = appSetting["LastActiveKeyboardLayout"]
  end
  Keycodes.setLayout(newLayout)
end

local function enterModalForActiveApp()
  for id, modal in pairs(modals) do
    if id == obj.frontAppBundleID then
      obj.activeModal = modal
      modal:enter()
    else
      modal:exit()
    end
  end
end

obj.lastNonTransientApp = nil

local function appWatcherCallback(_, event, appObj)
  local bundleID = appObj:bundleID()
  if event == Application.watcher.activated or event == "FROM_WINDOW_WATCHER" then
    if bundleID == obj.frontAppBundleID then
      return
    end
    obj.frontApp = appObj
    obj.frontAppBundleID = bundleID
    -- set input source
    setInputSource(bundleID)
    -- enter modal
    enterModalForActiveApp()

    if event ~= "FROM_WINDOW_WATCHER" then
      obj.lastNonTransientApp = appObj
    end
  end
  obj.appquitter:update(event, bundleID)
end

local additionalApps = {
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
  -- Window.filter.windowTitleChanged
  -- Window.filter.windowVisible,
  -- Window.filter.windowNotVisible,
  -- Window.filter.windowUnminimized,
  -- Window.filter.windowUnhidden,
}

local function windowFilterCallback(hsWindow, _, event)
  -- second arg is the app's name
  local appObj = hsWindow:application()
  if not appObj then
    return
  end
  local bundleID = appObj:bundleID()
  -- print(event, bundleID, obj.frontAppBundleID, obj.lastNonTransientApp)
  if (event == "windowFocused") or (event == "windowCreated") then
    if bundleID == obj.frontAppBundleID then
      return
    end
    appWatcherCallback(nil, "FROM_WINDOW_WATCHER", appObj)
  elseif event == "windowDestroyed" then
    appWatcherCallback(nil, Application.watcher.activated, hs.application.frontmostApplication())
  end
end

local function loadAppHotkeys()
  local hotkeysTable = dofile(script_path() .. "/app_hotkeys.lua")
  for bundleID, hotkeyList in pairs(hotkeysTable) do
    modals[bundleID] = Hotkey.modal.new()
    for _, action in pairs(hotkeyList) do
      modals[bundleID]:bind(table.unpack(action))
    end
  end
end

function obj.toggleInputSource()
  local currentLayout = Keycodes.currentLayout()
  local otherInputSource
  if currentLayout == "ABC" then
    otherInputSource = "Hebrew"
  else
    otherInputSource = "ABC"
  end
  Keycodes.setLayout(otherInputSource)

  if FNUtils.contains(keyboardLayoutSwitcherExcludedApps, obj.frontAppBundleID) then
    return
  end
  local settingsTable = Settings.get(appsLastActiveKeyboardLayoutsKey)
  settingsTable[obj.frontAppBundleID] = {
    ["LastActiveKeyboardLayout"] = otherInputSource,
    ["LastActiveKeyboardLayoutTimestamp"] = os.time()
  }
  Settings.set(appsLastActiveKeyboardLayoutsKey, settingsTable)
  --- special handling for safari
  -- if obj.frontAppBundleID == "com.apple.Safari" then
  --   local t = Settings.get(safariKeyboardLayoutsPerTabKey)
  --   t[getCurrentSafariTabInstance()] = otherInputSource
  --   Settings.set(safariKeyboardLayoutsPerTabKey, t)
  -- end
end

function obj:init()
  -- appquitter
  obj.appquitter:init()
  -- app modals
  loadAppHotkeys()

  URLEvent.bind("toggleInputSource", obj.toggleInputSource)

  self.appWatcher = Application.watcher.new(appWatcherCallback)
  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  self.appWatcher:start()
  self.windowFilter = Window.filter.new(false):setFilters(additionalApps)

  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)

  self.windowFilter:subscribe(allowedWindowFilterEvents, windowFilterCallback)

  windowFilterCallback(Application.frontmostApplication():mainWindow(), nil, "windowFocused")
end

return obj

-- local function safariWindowCallback(hsWindow, eventName)
--   -- safari override for tab switching
--   if hsWindow:application():name() == "Safari" then
--     if eventName == "windowTitleChanged" then
--       print("Safari Window Title Changed")
--       local prefsTable = Settings.get(safariKeyboardLayoutsPerTabKey)
--       local currentTab = getCurrentSafariTabInstance()
--       local savedKeyboardLayout = prefsTable[currentTab]
--       local layoutToSet
--       if savedKeyboardLayout then
--         layoutToSet = savedKeyboardLayout
--       else
--         layoutToSet = "ABC"
--       end
--       Keycodes.setLayout(layoutToSet)
--     end
--     return
--   end
-- end

-- local function getCurrentSafariTabInstance()
--   local safariMainWindow = AX.applicationElement(obj.frontApp):attributeValue("AXMainWindow")
--   local tabBar = UI.getUIElement(safariMainWindow, {{"AXGroup", 1}})
--   for _, tab in ipairs(tabBar) do
--     if tab:attributeValue("AXValue") then
--       return tab:attributeValue("AXIdentifier")
--     end
--   end
-- end

--- special handling for safari
-- if obj.frontAppBundleID == "com.apple.Safari" then
--   local t = Settings.get(safariKeyboardLayoutsPerTabKey)
--   t[getCurrentSafariTabInstance()] = otherInputSource
--   Settings.set(safariKeyboardLayoutsPerTabKey, t)
-- end
