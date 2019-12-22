local ax = require("hs._asm.axuielement")
local ui = require("util.ui")
local application = require("hs.application")
local Timer = require("hs.timer")
local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local Mouse = require("hs.mouse")
local OSAScript = require("hs.osascript")

local obj = {}

local function getPanel()
  local notifCenterPanel = application.applicationsForBundleID("com.apple.notificationcenterui")[1]:focusedWindow()
  if notifCenterPanel then return ax.windowElement(notifCenterPanel) end
end
local function getTodayButton() return ui.getUIElement(getPanel(), {{"AXRadioGroup", 1}, {"AXRadioButton", 1}}) end
local function getNotificationsButton() return ui.getUIElement(getPanel(), {{"AXRadioGroup", 1}, {"AXRadioButton", 2}}) end

function obj:toggle()
  local currentMousePos
  -- if panel isnt disclosed, open it and click on 'Today'
  -- else, toggle between modes
  if getPanel() then
    if getTodayButton():attributeValue("AXValue") == 1 then
      getNotificationsButton():performAction("AXPress")
    else
      getTodayButton():performAction("AXPress")
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
  Timer.doAfter(0.1, function() getTodayButton():doPress() end)
  Mouse.setAbsolutePosition(currentMousePos)
end

function obj:clickButton(arg)
  local app = application.applicationsForBundleID("com.apple.notificationcenterui")[1]
  local axApp = ax.applicationElement(app)
  local allWindows = axApp:children()
  for i, theWindow in ipairs(allWindows) do
    -- checking for a banner/alert style notification
    local button1 = ui.getUIElement(theWindow, {{"AXButton", 1}})
    -- a banner -> move mouse cursor to reveal the buttons
    if not button1 then
      local windowPosition = theWindow:position()
      local x = windowPosition.x + 10
      local y = windowPosition.y + 10
      local originalPosition = Mouse.getAbsolutePosition()
      Mouse.setAbsolutePosition({x = x, y = y})
      button1 = ui.getUIElement(theWindow, {{"AXButton", 1}})
      Timer.doAfter(0.5, function() Mouse.setAbsolutePosition(originalPosition) end)
    end

    if button1 then
      if arg == 1 then return button1:doPress() end
      if arg == 2 then
        local button2 = ui.getUIElement(theWindow, {{"AXMenuButton", 1}})
        if not button2 then return ui.getUIElement(theWindow, {{"AXButton", 2}}):doPress() end
        OSAScript.applescript(string.format([[
          ignoring application responses
            tell application "System Events" to tell application process "Notification Center" to tell window %s to click menu button 1
          end ignoring]], i))
        Timer.doAfter(0.2, function() button2:children()[1]:children()[1]:setAttributeValue("AXSelected", true) end)
        return
      end
    end
  end
end

return obj
