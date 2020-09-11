--- === NotificationCenter ===
---
--- Notification Center automations.
local ui = require("rb.ui")
local ax = require("hs._asm.axuielement")
local application = require("hs.application")
local Mouse = require("hs.mouse")
local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local Timer = require("hs.timer")
local hs = hs

local obj = {}

obj.__index = obj
obj.name = "NotificationCenter"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function getWindow()
  local notifCenterPanel = application.applicationsForBundleID("com.apple.notificationcenterui")[1]:focusedWindow()
  if notifCenterPanel then
    return ax.windowElement(notifCenterPanel)
  end
end

local function toggle()
  local function notificationCenterGetButton(theButton)
    -- today = 1, notifications = 2
    return ui.getUIElement(getWindow(), {{"AXRadioGroup", 1}, {"AXRadioButton", theButton}})
  end
  local currentMousePos
  -- if panel is shown, toggle between modes
  -- else, open it and click on 'Today'
  if getWindow() then
    if notificationCenterGetButton(1):attributeValue("AXValue") == 1 then
      notificationCenterGetButton(2):performAction("AXPress")
    else
      notificationCenterGetButton(1):performAction("AXPress")
    end
    return
  end
  currentMousePos = Mouse.getAbsolutePosition()
  local app = ax.applicationElement(application.applicationsForBundleID("com.apple.systemuiserver")[1])
  local menuBarIconPos =
    ui.getUIElement(app, {{"AXMenuBar", 1}, {"AXMenuBarItem", "AXTitle", "Notification Center"}}):position()
  local x = menuBarIconPos.x + 10
  local y = menuBarIconPos.y + 10
  eventtap.leftClick(geometry.point({x, y}))
  Mouse.setAbsolutePosition(currentMousePos)
  Timer.doAfter(
    0.2,
    function()
      notificationCenterGetButton(1):doPress()
    end
  )
end

local function clickButton(theButton)
  local app = application.applicationsForBundleID("com.apple.notificationcenterui")[1]
  local axApp = ax.applicationElement(app)
  local allWindows = axApp:children()
  for _, theWindow in ipairs(allWindows) do
    local button1 = ui.getUIElement(theWindow, {{"AXButton", 1}})
    -- checking for a banner/alert style notification
    -- if a banner, move mouse cursor to reveal the buttons
    -- "button" 3 -> click on the banner and return
    if not button1 or theButton == 3 then
      local windowPosition = theWindow:position()
      local x = windowPosition.x + 10
      local y = windowPosition.y + 10
      local originalPosition = Mouse.getAbsolutePosition()
      local newPosition = {x = x, y = y}
      Mouse.setAbsolutePosition(newPosition)
      button1 = ui.getUIElement(theWindow, {{"AXButton", 1}})
      Timer.doAfter(
        0.5,
        function()
          Mouse.setAbsolutePosition(originalPosition)
        end
      )
      if theButton == 3 then
        eventtap.leftClick(newPosition)
        return
      end
    end
    if button1 then
      if theButton == 1 then
        button1:doPress()
        return
      end
      if theButton == 2 then
        local button2 = ui.getUIElement(theWindow, {{"AXMenuButton", 1}})
        if not button2 then
          ui.getUIElement(theWindow, {{"AXButton", 2}}):doPress()
          return
        end
        ui.getUIElement(theWindow, {{"AXMenuButton", 1}}):setTimeout(0.2):doPress()
        button2:children()[1]:children()[1]:setAttributeValue("AXSelected", true)
      end
    end
  end
end

function obj:bindHotKeys(_mapping)
  local def = {
    firstButton = function()
      clickButton(1)
    end,
    secondButton = function()
      clickButton(2)
    end,
    thirdButton = function()
      clickButton(3)
    end,
    toggle = function()
      toggle()
    end
  }
  hs.spoons.bindHotkeysToSpec(def, _mapping)
  return self
end

return obj
