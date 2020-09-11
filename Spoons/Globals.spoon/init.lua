--- === Globals ===
---
--- Miscellaneous automations that are not app-specific.
local application = require("hs.application")
local ax = require("hs._asm.axuielement")
local hs = hs

local obj = {}

obj.__index = obj
obj.name = "Globals"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function focusMenuBar()
  ax.systemElementAtPosition({0, 0}):attributeValue("AXParent")[2]:doPress()
end

local function rightClick()
  ax.applicationElement(application.frontmostApplication()):focusedUIElement():performAction("AXShowMenu")
end

function obj:bindHotKeys(_mapping)
  local def = {
    rightClick = function()
      rightClick()
    end,
    focusMenuBar = function()
      focusMenuBar()
    end
  }
  hs.spoons.bindHotkeysToSpec(def, _mapping)
  return self
end

return obj

-- local function lookUpInDictionary()
--   eventtap.keyStroke({"cmd"}, "c")
--   Timer.doAfter(
--     0.4,
--     function()
--       local arg = "dict://" .. pasteboard.getContents()
--       Task.new("/usr/bin/open", nil, {arg}):start()
--     end
--   )
-- end

-- local function moveFocusToTheDock()
--   ui.getUIElement(application("Dock"), {{"AXList", 1}}):setAttributeValue("AXFocused", true)
-- end

-- local function showHelpMenu()
--   Keycodes.setLayout("ABC")
--   local menuBar = ax.systemElementAtPosition({0, 0}):attributeValue("AXParent")
--   for _, v in ipairs(menuBar) do
--     if v:attributeValue("AXTitle") == "Help" then
--       return v:doPress()
--     end
--   end
-- end
