local Application = require("hs.application")
local Window = require("hs.window")
local FNUtils = require("hs.fnutils")
local Timer = require("hs.timer")
local Settings = require("hs.settings")
local Keycodes = require("hs.keycodes")
local URLEvent = require("hs.urlevent")
local FS = require("hs.fs")
local Hotkey = require("hs.hotkey")
local AX = require("hs._asm.axuielement")
local UI = require("rb.ui")

local settingKeys = settingKeys
local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

local appsLastActiveKeyboardLayoutsKey = settingKeys.appsLastActiveKeyboardLayouts
-- local safariTabsKeyboardLayoutsKey = settingKeys.safariTabsKeyboardLayouts

obj.helpers = script_path() .. "/helpers"
obj.appquitter = dofile(script_path() .. "/appquitter.lua")

obj.__index = obj
obj.name = "AppWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.appWatcher = nil
obj.windowFilter = nil

-- important global variables, shared across HS env
obj.frontApp = nil
obj.frontAppBundleID = nil
obj.activeModal = nil

obj.appFunctions = {}
obj.appActions = {}

local modals = {}
obj.modals = modals -- cheatsheet?

obj.runningApplications = {}
obj.timer = nil

local transientApps = {
  "LaunchBar",
  "1Password 7",
  "Contexts",
  "Emoji & Symbols",
  "Spotlight",
  "Safari"
  -- "Hammerspoon"
}

local keyboardLayoutSwitcherExcludedApps = {
  "at.obdev.LaunchBar",
  "com.apple.Safari"
}

local allowedWindowFilterEvents = {
  Window.filter.windowCreated,
  Window.filter.windowDestroyed,
  Window.filter.windowTitleChanged
  -- Window.filter.windowFocused,
  -- Window.filter.windowVisible,
  -- Window.filter.windowNotVisible,
  -- Window.filter.windowUnminimized,
  -- Window.filter.windowUnhidden,
}

---

local function getCurrentSafariTabInstance()
  -- local safariMainWindow = AX.applicationElement(obj.frontApp):attributeValue("AXMainWindow")
  -- local tabBar = UI.getUIElement(safariMainWindow, {{"AXGroup", 1}})
  -- for _, tab in ipairs(tabBar) do
  --   if tab:attributeValue("AXValue") then
  --     return tab:attributeValue("AXIdentifier")
  --   end
  -- end
end

---

local function toggleInputSource()
  local currentLayout = Keycodes.currentLayout()
  local otherInputSource
  if currentLayout == "ABC" then
    otherInputSource = "Hebrew"
  else
    otherInputSource = "ABC"
  end
  Keycodes.setLayout(otherInputSource)

  -- if obj.frontAppBundleID == "com.apple.Safari" then
  --   local t = Settings.get("RBSafariTabsKeyboardLayouts")
  --   t[getCurrentSafariTabInstance()] = otherInputSource
  --   Settings.set("RBSafariTabsKeyboardLayouts", t)
  -- end

  if FNUtils.contains(keyboardLayoutSwitcherExcludedApps, obj.frontAppBundleID) then
    return
  end
  local settingsTable = Settings.get(appsLastActiveKeyboardLayoutsKey)
  settingsTable[obj.frontAppBundleID] = {
    ["LastActiveKeyboardLayout"] = otherInputSource,
    ["LastActiveKeyboardLayoutTimestamp"] = os.time()
  }
  Settings.set(appsLastActiveKeyboardLayoutsKey, settingsTable)
end

local function setInputSource(bundleid)
  local settingsTable = Settings.get(appsLastActiveKeyboardLayoutsKey)
  local appSetting = settingsTable[bundleid]
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

---

local function appWatcherCallback(_, event, appObj)
  local bundleID = appObj:bundleID()
  if (event == Application.watcher.activated) then
    obj.frontApp = appObj
    if obj.frontAppBundleID == bundleID then
      return
    end
    obj.frontAppBundleID = bundleID
    setInputSource(bundleID)
    enterModalForActiveApp()
    print("active app  ==> ", bundleID)
  end

  -- obj.appquitter:update(event, bundleID)
end

---

local function windowFilterCallback(hsWindow, appNameString, eventName)
  -- safari override for tab switching
  if hsWindow:application():name() == "Safari" then
    if eventName == "windowTitleChanged" then
      --   local prefsTable = Settings.get("RBSafariTabsKeyboardLayouts")
      local currentTab = getCurrentSafariTabInstance()
    --   local savedKeyboardLayout = prefsTable[currentTab]
    --   local layoutToSet
    --   if savedKeyboardLayout then
    --     layoutToSet = savedKeyboardLayout
    --   else
    --     layoutToSet = "ABC"
    --   end
    --   Keycodes.setLayout(layoutToSet)
    end
    return
  end
  if eventName == "windowCreated" then
    appWatcherCallback(nil, Application.watcher.activated, hsWindow:application())
  elseif eventName == "windowDestroyed" then
    Timer.doAfter(
      0.1,
      function()
        appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
      end
    )
  end
end

---

local function loadAppFunctions()
  local scriptsFolder = script_path() .. "/app_functions"
  local iterFn, dirObj = FS.dir(scriptsFolder)
  if iterFn then
    for file in iterFn, dirObj do
      if file:sub(-4) == ".lua" then
        local appFile = dofile(scriptsFolder .. "/" .. file)
        local id = appFile.id
        obj.appFunctions[id] = appFile
      end
    end
  end
end

---

local function loadAppHotkeys()
  local hotkeysTable = dofile(script_path() .. "/hotkeys.lua")
  for bundleID, hotkeyList in pairs(hotkeysTable) do
    modals[bundleID] = Hotkey.modal.new()
    for _, action in pairs(hotkeyList) do
      modals[bundleID]:bind(table.unpack(action))
    end
  end
end

---

local function loadAppActions()
  local actionsTable = dofile(script_path() .. "/actions.lua")
  for bundleID, actionList in pairs(actionsTable) do
    obj.appActions[bundleID] = actionList
  end
end

---

local function windowFilterPredicate(windowObj)
  local app = windowObj:application():name()
  if FNUtils.contains(transientApps, app) then
    return true
  end
  return false
end

---

function obj:init()
  URLEvent.bind("toggleInputSource", toggleInputSource)
  self.appWatcher = Application.watcher.new(appWatcherCallback)
  self.windowFilter = Window.filter.new(windowFilterPredicate)
  loadAppFunctions()
  loadAppHotkeys()
  loadAppActions()

  -- obj.appquitter:init()

  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  self.appWatcher:start()
  self.windowFilter:subscribe(allowedWindowFilterEvents, windowFilterCallback)
end

return obj
