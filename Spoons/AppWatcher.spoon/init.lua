local Application = require("hs.application")
local Window = require("hs.window")
local FNUtils = require("hs.fnutils")
local Settings = require("hs.settings")
local Keycodes = require("hs.keycodes")
local URLEvent = require("hs.urlevent")
local Hotkey = require("hs.hotkey")
local AX = require("hs._asm.axuielement")
local Observer = AX.observer
local UI = require("rb.ui")

local obj = {}
local modals = {}

local additionalApps = {
  ["LaunchBar"] = {allowRoles = "AXSystemDialog"},
  ["1Password 7"] = {allowRoles = "AXSystemDialog"},
  ["Spotlight"] = {allowRoles = "AXSystemDialog"},
  ["Contexts"] = false,
  ["Emoji & Symbols"] = true
  -- ["Safari"] = true
}

local allowedWindowFilterEvents = {
  Window.filter.windowCreated,
  Window.filter.windowDestroyed,
  Window.filter.windowFocused,
  Window.filter.windowTitleChanged -- only for safari
  -- Window.filter.windowVisible,
  -- Window.filter.windowNotVisible,
  -- Window.filter.windowUnminimized,
  -- Window.filter.windowUnhidden,
}

local keyboardLayoutSwitcherExcludedApps = {
  "at.obdev.LaunchBar",
  "com.contextsformac.Contexts"
}

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.__index = obj
obj.name = "AppWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.appquitter = dofile(script_path() .. "/appquitter.lua")
obj.windowFilter = nil
obj.frontApp = nil
obj.frontAppBundleID = nil
obj.activeModal = nil
obj.timer = nil
obj.lastNonTransientApp = nil

obj.appFunctions = {}
obj.appActions = {}
obj.runningApplications = {}

obj.safariAddressBar = nil
obj.safariPid = nil
obj.safariObserver = nil
obj.layoutsForURL = {}

local function extractTopLevelURL(url)
  for _, v in ipairs(hs.fnutils.split(url, "/")) do
    if v and string.find(v, "%.") then
      url = v
      break
    end
  end
  return url
end

local function addSafariObserver(appObj)
  local element
  local axAppObj = AX.applicationElement(appObj)
  local addressBarObject = UI.getUIElement(axAppObj, {{"AXWindow", "AXMain", true}, {"AXToolbar", 1}}):attributeValue("AXChildren")
  for _, toolbarObject in ipairs(addressBarObject) do
    local toolbarObjectsChilds = toolbarObject:attributeValue("AXChildren")
    if toolbarObjectsChilds then
      for _, toolbarObjectChild in ipairs(toolbarObjectsChilds) do
        if toolbarObjectChild:attributeValue("AXRole") == "AXTextField" then
          element = toolbarObjectChild
          obj.safariAddressBar = element
          break
        end
      end
    end
  end
  local pid = appObj:pid()
  local observer = Observer.new(pid)
  observer:addWatcher(element, "AXValueChanged")
  observer:callback(
    function()
      -- don't change layout while typing addresses!
      local url = element:attributeValue("AXValue")
      if not url or url == "" then
        Keycodes.setLayout("ABC")
        return
      end
      if obj.safariAddressBar:attributeValue("AXFocused") == true then
        return
      end
      local topLevelURL = extractTopLevelURL(url)
      local newLayout = "ABC"
      local settingsTable = Settings.get("RBSafariLayoutsForURL") or {}
      local urlSetting = settingsTable[topLevelURL]
      if urlSetting then
        newLayout = urlSetting
      end
      print(topLevelURL, newLayout, hs.inspect(settingsTable))
      Keycodes.setLayout(newLayout)
    end
  )
  observer:start()
end

local function setInputSource(bundleid)
  -- default to abc if no saved setting
  local newLayout = "ABC"
  -- special handling for safari
  local settingsTable = Settings.get("RBAppsLastActiveKeyboardLayouts") or {}
  local appSetting = settingsTable[bundleid]
  if appSetting then
    -- TODO: reset back to abc based on timestamp?
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

local function appWatcherCallback(_, event, appObj)
  local bundleID = appObj:bundleID()
  if bundleID == "com.apple.Safari" then
    addSafariObserver(appObj)
  end
  if event == Application.watcher.activated or event == "FROM_WINDOW_WATCHER" then
    if bundleID == obj.frontAppBundleID then
      return
    end
    obj.frontApp = appObj
    obj.frontAppBundleID = bundleID
    setInputSource(bundleID) -- set input source
    enterModalForActiveApp() -- enter modal
    if event ~= "FROM_WINDOW_WATCHER" then
      obj.lastNonTransientApp = appObj
    end
  end
  obj.appquitter:update(event, bundleID)
end

local function windowFilterCallback(hsWindow, _, event) -- second arg is the app's name
  local appObj = hsWindow:application()
  if not appObj then
    return
  end
  local bundleID = appObj:bundleID()
  if event == "windowFocused" or event == "windowCreated" then
    if bundleID == obj.frontAppBundleID then
      return
    end
    appWatcherCallback(nil, "FROM_WINDOW_WATCHER", appObj)
  elseif event == "windowDestroyed" then
    appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
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
  local bundleID = obj.frontAppBundleID
  local currentLayout = Keycodes.currentLayout()
  local newLayout
  if currentLayout == "ABC" then
    newLayout = "Hebrew"
  else
    newLayout = "ABC"
  end
  Keycodes.setLayout(newLayout)

  if FNUtils.contains(keyboardLayoutSwitcherExcludedApps, bundleID) then
    return
  end
  if bundleID == "com.apple.Safari" then
    local settingsTable = Settings.get("RBSafariLayoutsForURL") or {}
    local url = obj.safariAddressBar:attributeValue("AXValue")
    local topLevelURL = extractTopLevelURL(url)
    settingsTable[topLevelURL] = newLayout
    Settings.set("RBSafariLayoutsForURL", settingsTable)
  else
    local settingsTable = Settings.get("RBAppsLastActiveKeyboardLayouts") or {}
    settingsTable[obj.frontAppBundleID] = {
      ["LastActiveKeyboardLayout"] = newLayout,
      ["LastActiveKeyboardLayoutTimestamp"] = os.time()
    }
    Settings.set("RBAppsLastActiveKeyboardLayouts", settingsTable)
  end
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
