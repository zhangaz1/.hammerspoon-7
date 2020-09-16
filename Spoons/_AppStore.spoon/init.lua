--- === AppStore ===
---
--- AppStore automations.
local UI = require("rb.ui")
local Hotkey = require("hs.hotkey")
local hs = hs

local obj = {}
local _modal = nil
local _appObj = nil

obj.bundleID = "com.apple.AppStore"

obj.__index = obj
obj.name = "AppStore"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function goBack(appObj)
  UI.getUIElement(appObj:mainWindow(), {{"AXGroup", 1}, {"AXButton", "AXTitle", "Go Back"}}):performAction("AXPress")
end

local hotkeys = {
  {
    "cmd",
    "[",
    function()
      goBack(_appObj)
    end
  }
}

function obj:start(appObj)
  _appObj = appObj
  _modal:enter()
end

function obj:stop()
  _modal:exit()
end

function obj:init()
  if not obj.bundleID then
    hs.showError("bundle indetifier for app spoon is nil")
  end
  _modal = Hotkey.modal.new()
  for _, v in ipairs(hotkeys) do
    _modal:bind(table.unpack(v))
  end
end

return obj

-- local function getFinderSelectionCount()
--   local selection = getFinderSelection()
--   if not selection then
--     return 0
--   end
--   local n = 0
--   for i, _ in ipairs(selection) do
--     n = i
--   end
--   return n
-- end

-- local function nextSearchScope(appObj)
--   local searchScopesBar = {
--     {"AXWindow", 1},
--     {"AXSplitGroup", 1},
--     {"AXGroup", 1},
--     {"AXRadioGroup", 1}
--   }
--   return ui.cycleUIElements(appObj, searchScopesBar, "AXRadioButton", "next")
-- end
