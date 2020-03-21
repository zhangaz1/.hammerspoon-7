local Application = require("hs.application")
local Window = require("hs.window")
local FNUtils = require("hs.fnutils")
local Timer = require("hs.timer")
local Settings = require("hs.settings")
local Keycodes = require("hs.keycodes")
local URLEvent = require("hs.urlevent")
local FS = require("hs.fs")
local Hotkey = require("hs.hotkey")
local UI = require("rb.ui")
local AX = require("hs._asm.axuielement")

local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

obj.helpers = script_path() .. "/helpers"

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
local modals = {}
obj.appActions = {}

obj.modals = modals -- cheatsheet?

obj.runningApplications = nil
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

local minute = 60
local hour = 60 * minute
local appQuitterRulesTable = {
  ["at.obdev.LaunchBar.ActionEditor"] = {
    shouldQuitAfter = minute
  },
  ["com.kapeli.dashdoc"] = {
    shouldQuitAfter = minute
  }
}



local function getCurrentSafariTabInstance()
  local safariMainWindow = AX.applicationElement(obj.frontApp):attributeValue("AXMainWindow")
  local tabBar = UI.getUIElement(safariMainWindow, {{"AXGroup", 1}})
  for _, tab in ipairs(tabBar) do
    if tab:attributeValue("AXValue") then
      return tab:attributeValue("AXIdentifier")
    end
  end
end


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
  --   local t = Settings.get("SafariTabsKeyboardLayouts")
  --   t[getCurrentSafariTabInstance()] = otherInputSource
  --   Settings.set("SafariTabsKeyboardLayouts", t)
  -- end

  if FNUtils.contains(keyboardLayoutSwitcherExcludedApps, obj.frontAppBundleID) then
    return
  end
  local settingsTable = Settings.get("AppsLastActiveKeyboardLayouts")
  settingsTable[obj.frontAppBundleID] = {
    ["LastActiveKeyboardLayout"] = otherInputSource,
    ["LastActiveKeyboardLayoutTimestamp"] = os.time(),
  }
  Settings.set("AppsLastActiveKeyboardLayouts", settingsTable)
end


local function appWatcherCallback(_, event, appObj)
  if (event == Application.watcher.activated) then
    local bundleID = appObj:bundleID()
    obj.frontApp = appObj
    if obj.frontAppBundleID == bundleID then
      return
    end
    obj.frontAppBundleID = bundleID

    -- BEGIN qpp quitter
    local settingsTable = Settings.get("AppsLastActivationDates")
    for k, v in pairs(appQuitterRulesTable) do
      if k == bundleID then
        local lastActiveTimestamp = os.time()
        local lastActiveHumanReadable = os.date()
        local shouldQuitAtTimestamp = lastActiveTimestamp + v.shouldQuitAfter
        local shouldQuitAtHumanReadable = os.date("%c", shouldQuitAtTimestamp)
        settingsTable[bundleID] = {
          ["LastActiveTimestamp"] = lastActiveTimestamp,
          ["LastActiveHumanReadable"] = lastActiveHumanReadable,
          ["ShouldQuitAtTimestamp"] = shouldQuitAtTimestamp,
          ["ShouldQuitAtHumanReadable"] = shouldQuitAtHumanReadable
        }
        Settings.set("AppsLastActivationDates", settingsTable)
        break
      end
    end
    -- END qpp quitter

    -- BEGIN keyboard layout switcher
    settingsTable = Settings.get("AppsLastActiveKeyboardLayouts")
    local newLayout
    local appSetting = settingsTable[bundleID]
    -- TIMESTAMP!
    if appSetting then
      newLayout = appSetting["LastActiveKeyboardLayout"]
    else
      newLayout = "ABC"
    end
    Keycodes.setLayout(newLayout)
    -- END keyboard layout switcher

    -- enter active modal
    for id, modal in pairs(modals) do
      if id == obj.frontAppBundleID then
        obj.activeModal = modal
        print("active modal  ==> ", bundleID)
        modal:enter()
      else
        modal:exit()
      end
    end

  end
end

local function windowFilterCallback(hsWindow, _, eventName)
  -- _ = appNameString
  --
  -- if eventName == "windowTitleChanged" then
  --   if hsWindow:application():name() == "Safari" then
  --     local prefsTable = Settings.get("SafariTabsKeyboardLayouts")
  --     local currentTab = getCurrentSafariTabInstance()
  --     local savedKeyboardLayout = prefsTable[currentTab]
  --     local layoutToSet
  --     print(hs.inspect(prefsTable), currentTab)
  --     if savedKeyboardLayout then
  --       layoutToSet = savedKeyboardLayout
  --     else
  --       layoutToSet = "ABC"
  --     end
  --     Keycodes.setLayout(layoutToSet)
  --   end
  --   return
  -- end
  --

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

local function loadAppHotkeys()
  local hotkeysTable = dofile(script_path() .. "/hotkeys.lua")
  for bundleID, hotkeyList in pairs(hotkeysTable) do
    modals[bundleID] = Hotkey.modal.new()
    for _, action in pairs(hotkeyList) do
        modals[bundleID]:bind(table.unpack(action))
    end
  end
end

local function loadAppActions()
  local actionsTable = dofile(script_path() .. "/actions.lua")
  for bundleID, actionList in pairs(actionsTable) do
    obj.appActions[bundleID] = actionList
  end
end

function obj:init()

  URLEvent.bind("toggleInputSource", toggleInputSource)

  for _, v in ipairs({"AppsLastActivationDates", "AppsLastActiveKeyboardLayouts", "SafariTabsKeyboardLayouts"}) do
    if not Settings.get(v) then
      Settings.set(v, {})
    end
  end

    -- BEGIN app quitter
    hs.timer.doEvery(
      60,
      function()
        local settingsTable = Settings.get("AppsLastActivationDates")
        for k, v in pairs(settingsTable) do
          if os.time() > v["ShouldQuitAtTimestamp"] then
            print(k, " ===> should quit...")
          end
        end
      end
    )
    -- END app quitter

  self.appWatcher = Application.watcher.new(appWatcherCallback)
  self.windowFilter =
    Window.filter.new(
    function(windowObj)
      local app = windowObj:application():name()
      if FNUtils.contains(transientApps, app) then
        return true
      end
      return false
    end
  )

  -- obj.runningApplications = Application.runningApplications()
  -- obj.applicationModals = spoon.Hotkeys.modals

  loadAppFunctions()
  loadAppHotkeys()
  loadAppActions()

  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
  self.appWatcher:start()
  self.windowFilter:subscribe(allowedWindowFilterEvents, windowFilterCallback):resume()

end

return obj
