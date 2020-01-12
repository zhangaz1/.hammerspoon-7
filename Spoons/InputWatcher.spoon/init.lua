local EventTap = require("hs.eventtap")
local KeyCodes = require("hs.keycodes")
local Timer = require("hs.timer")

local UI = require("rb.ui")
local Util = require("rb.util")

local obj = {}

obj.__index = obj
obj.name = "InputWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function getFrontApp()
  -- return hs.application.frontmostApplication()
  return spoon.AppWatcher.frontApp
end

local function getFrontAppID()
  return getFrontApp():bundleID()
end

local function watcherCallback(event)
  local keyCode = event:getKeyCode()
  local eventFlags = event:getFlags()
  local currentLayout = KeyCodes.currentLayout()
  if keyCode == KeyCodes.map.space then
    if eventFlags:containExactly({"ctrl", "cmd"}) or eventFlags:containExactly({"alt"}) then
      if currentLayout == "ABC" then
        return
      end
      KeyCodes.setLayout("ABC")
    end
  end

  if getFrontAppID() == "desktop.WhatsApp" then
    if (keyCode == KeyCodes.map.f) and eventFlags:containExactly({"cmd"}) then
      if currentLayout == "ABC" then
        return
      end
      KeyCodes.setLayout("ABC")
    end
    if (keyCode == KeyCodes.map["return"] or keyCode == KeyCodes.map.tab) and eventFlags:containExactly({}) then
      if currentLayout == "Hebrew" then
        return
      end
      KeyCodes.setLayout("Hebrew")
    end
  end

  if getFrontAppID() == "com.apple.Safari" then
    local safari = getFrontApp()
    if keyCode == KeyCodes.map["return"] and eventFlags:containExactly({}) then
      Timer.doAfter(
        0.5,
        function()
          if Util.isSafariAddressBarFocused(safari) then
            Util.moveFocusToSafariMainArea(safari, true)
          end
        end
      )
    end
  end

  if getFrontAppID() == "com.apple.finder" then
    -- focus of the files area must be checked first,
    -- checking for selection count if a pop up is open causes a timeout!
    if keyCode == KeyCodes.map["return"] and eventFlags:containExactly({}) then
      local finder = getFrontApp()
      if Util.isFilesAreaFocused(finder) then
        if Util.selectionCount() > 1 then
          local menuItems =
            UI.getUIElement(
            finder,
            {
              {"AXMenuBar", 1},
              {"AXMenuBarItem", "AXTitle", "File"},
              {"AXMenu", 1}
            }
          ):attributeValue("AXChildren")
          for _, v in ipairs(menuItems) do
            local title = v:attributeValue("AXTitle")
            if string.find(title, "Rename") then
              return v:performAction("AXPress")
            end
          end
        end
      end
    end
  end
end

obj.watcher = nil

function obj:init()
  self.watcher = EventTap.new({EventTap.event.types.keyUp}, watcherCallback):start()
end

function obj:stop()
  self.watcher:stop()
end

function obj:start()
  self.watcher:start()
end

return obj
