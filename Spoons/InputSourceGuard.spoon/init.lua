local Settings = require("hs.settings")
local KeyCodes = require("hs.keycodes")
local MenuBar = require("hs.menubar")

local obj = {}

obj.__index = obj
obj.name = "InputSourceGuard"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.menuBarItem = nil

local function currentState()
  return Settings.get("forceABC")
end

function obj:start(appObj)
  -- initialize if not previously set, default to enabled
  if not currentState() then
    Settings.set("forceABC", "enabled")
  end
  if currentState() == "enabled" then
    if appObj and appObj:bundleID() == "desktop.WhatsApp" then
      KeyCodes.setLayout("Hebrew")
    else
      KeyCodes.setLayout("ABC")
    end
    obj.menuBarItem:removeFromMenuBar():setTitle("HEB")
  else
    obj.menuBarItem:returnToMenuBar():setTitle("HEB")
  end
end

function obj:toggle()
  if currentState() == "enabled" then
    Settings.set("forceABC", "disabled")
  elseif currentState() == "disabled" then
    Settings.set("forceABC", "enabled")
  end
  obj:start()
end

function obj:init()
  self.menuBarItem = MenuBar.new()
end

return obj
