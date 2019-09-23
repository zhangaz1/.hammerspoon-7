local ax = require("hs._asm.axuielement")
local ui = require("util.ui")
local application = require("hs.application")
local hotkey = require("hs.hotkey")
local timer = require("hs.timer")
local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local mouse = require("hs.mouse")
local fs = require("hs.fs")
local task = require("hs.task")

-- Notification Center
local hyper = {"cmd", "alt", "ctrl", "shift"}
local appleScript = fs.pathToAbsolute('util/notificationCenterButtons.scpt')

local function exec(arg)
  -- print(appleScript, arg)
  task.new('/usr/bin/osascript', nil, {appleScript, arg}):start()
end

local function notificationCenterMenuBar()
  local currentMousePos
  local function getPanel()

    local notifCenterPanel = application.applicationsForBundleID("com.apple.notificationcenterui")[1]:focusedWindow()
    if not notifCenterPanel then
      return nil
    else
      return ax.windowElement(notifCenterPanel)
    end
  end

  local function getTodayButton()
    local todayButton = ui.getUIElement( getPanel(), { {"AXRadioGroup", 1}, {"AXRadioButton", 1} } )
    return todayButton
  end

  local function getNotificationsButton()
    local notificationsButton = ui.getUIElement( getPanel(), { {"AXRadioGroup", 1}, {"AXRadioButton", 2} } )
    return notificationsButton
  end

  -- if panel isnt disclosed, open it and click on 'Today'
  if not getPanel() then
    -- else, toggle between modes
    currentMousePos = mouse.getAbsolutePosition()
    local app = ax.applicationElement(application.applicationsForBundleID("com.apple.systemuiserver")[1])
    local menuBarIconPos =
      ui.getUIElement(
      app,
      { {"AXMenuBar", 1}, {"AXMenuBarItem", "AXTitle", "Notification Center"} }
    ):attributeValue("AXPosition")
    local x = menuBarIconPos.x + 10
    local y = menuBarIconPos.y + 10
    eventtap.leftClick(geometry.point({x, y}))
    timer.doAfter(0.1, function() getTodayButton():performAction("AXPress") end)
    mouse.setAbsolutePosition(currentMousePos)
  else
    if getTodayButton():attributeValue("AXValue") == 1 then
      getNotificationsButton():performAction("AXPress")
    else
      getTodayButton():performAction("AXPress")
    end
  end
end

-- Button 1
hs.hotkey.bind(hyper, "1", function() exec("1") end)
-- Button 2
hs.hotkey.bind(hyper, "2", function() exec("2") end)
-- Click On
hs.hotkey.bind(hyper, "4", function() exec("clickOn") end)
-- menu bar
hotkey.bind(hyper, "n", function() notificationCenterMenuBar() end)
