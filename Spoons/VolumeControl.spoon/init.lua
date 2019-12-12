local AX = require("hs._asm.axuielement")
local Observer = require("hs._asm.axuielement").observer
local UI = require("util.ui")
local Application = require("hs.application")
local Hotkey = require("hs.hotkey")
local EventTap = require("hs.eventtap")

local obj = {}

obj.modal = nil
obj.__index = obj
obj.name = "VolumeControl"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local observer = nil
local slider = nil

function obj.modifyVolume(direction, withRepeat)
  for _ = 1, withRepeat do
    if direction == "up" then
      slider:doIncrement()
    else
      slider:doDecrement()
    end
  end
end

function obj.observerCallback()
  hs.printf("volume popover closed...")
  observer:stop()
  obj.modal:exit()
end

function obj:start()
  local app = Application("com.apple.systemuiserver")
  local axApp = AX.applicationElement(app)
  local pid = app:pid()
  local menuBarItems =
    UI.getUIElement(
    axApp,
    {
      {"AXMenuBar", 1}
    }
  ):children()
  for _, menuBarItem in ipairs(menuBarItems) do
    local description = menuBarItem:description()
    if description:match("volume") then
      menuBarItem:doPress()
      local subMenu = menuBarItem:children()[1]
      local subMenuChildren = subMenu:children()
      for _, menuItem in ipairs(subMenuChildren) do
        if menuItem.children and menuItem:children()[1] and (menuItem:children()[1]:role() == "AXSlider") then
          slider = menuItem:children()[1]
          break
        end
      end
      self.modal:enter()
      observer = Observer.new(pid):addWatcher(subMenu, "AXMenuClosed"):callback(obj.observerCallback):start()
      break
    end
  end
end

function obj:init()
  self.modal = Hotkey.modal.new()
  local hotkeySettings = {
    {
      {},
      "right",
      function()
        obj.modifyVolume("up", 1)
      end,
      nil,
      function()
        obj.modifyVolume("up", 1)
      end
    },
    {
      {},
      "left",
      function()
        obj.modifyVolume("down", 1)
      end,
      nil,
      function()
        obj.modifyVolume("down", 1)
      end
    },
    {
      {"shift"},
      "right",
      function()
        obj.modifyVolume("up", 4)
      end
    },
    {
      {"shift"},
      "left",
      function()
        obj.modifyVolume("down", 4)
      end
    },
    {
      {},
      "return",
      function()
        EventTap.keyStroke({}, "escape")
      end
    }
  }
  for _, v in ipairs(hotkeySettings) do
    self.modal:bind(table.unpack(v))
  end
end


return obj
