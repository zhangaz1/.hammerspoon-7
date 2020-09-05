local Keycodes = require("hs.keycodes")
local Settings = require("hs.settings")
local FNUtils = require("hs.fnutils")
local Spoons = require("hs.spoons")

local obj = {}

obj.__index = obj
obj.name = "KeyboardLayoutManager"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local _frontAppBundleID = nil

local keyboardLayoutSwitcherExcludedApps = {
  "at.obdev.LaunchBar",
  "com.contextsformac.Contexts"
}

local function toggleInputSource()
  local bundleID = _frontAppBundleID
  local currentLayout = Keycodes.currentLayout()
  local newLayout = "ABC"
  if currentLayout == "ABC" then
    newLayout = "Hebrew"
  end
  Keycodes.setLayout(newLayout)
  if FNUtils.contains(keyboardLayoutSwitcherExcludedApps, bundleID) then
    return
  end

  if bundleID == "com.apple.Safari" then
    spoon._Safari:saveLayoutForCurrentURL(newLayout)
  end

  local settingsTable = Settings.get("RBAppsLastActiveKeyboardLayouts") or {}
  settingsTable[_frontAppBundleID] = {
    ["LastActiveKeyboardLayout"] = newLayout,
    ["LastActiveKeyboardLayoutTimestamp"] = os.time()
  }
  Settings.set("RBAppsLastActiveKeyboardLayouts", settingsTable)
end

function obj:setInputSource(bundleid)
  _frontAppBundleID = bundleid
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

function obj:bindHotKeys(_mapping)
  local def = {
    toggleInputSource = function()
      toggleInputSource()
    end
  }
  Spoons.bindHotkeysToSpec(def, _mapping)
end

return obj
