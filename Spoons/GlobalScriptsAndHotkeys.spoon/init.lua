local application = require("hs.application")
local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local keycodes = require("hs.keycodes")
local Mouse = require("hs.mouse")
local OSAScript = require("hs.osascript")
local pasteboard = require("hs.pasteboard")
local Timer = require("hs.timer")
local Hotkey = require("hs.hotkey")
local Window = require("hs.window")
local GlobalChooser = require("rb.fuzzychooser")
local Image = require("hs.image")
local Task = require("hs.task")

local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")

local spoon = spoon

local obj = {}

obj.__index = obj
obj.name = "GlobalScriptsAndHotkeys"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local hyper = {"shift", "cmd", "alt", "ctrl"}

local function getFrontAppBundleID()
  return spoon.AppWatcher.frontAppBundleID
end

local function getAppActions()
  return spoon.AppWatcher.appActions
end

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local function notificationCenterGetPanel()
  local notifCenterPanel = application.applicationsForBundleID("com.apple.notificationcenterui")[1]:focusedWindow()
  if notifCenterPanel then
    return ax.windowElement(notifCenterPanel)
  end
end

local function notificationCenterGetButton(theButton)
  -- today = 1, notifications = 2
  return ui.getUIElement(notificationCenterGetPanel(), {{"AXRadioGroup", 1}, {"AXRadioButton", theButton}})
end

obj.spoonPath = script_path()

function obj.moveFocusToTheDock()
  ui.getUIElement(application("Dock"), {{"AXList", 1}}):setAttributeValue("AXFocused", true)
end

function obj.lookUpInDictionary()
  eventtap.keyStroke({"cmd"}, "c")
  Timer.doAfter(
    0.4,
    function()
      local arg = "dict://" .. pasteboard.getContents()
      Task.new("/usr/bin/open", nil, {arg}):start()
    end
  )
end

function obj.showHelpMenu()
  -- BEGIN HEBREW SUPPORT
  keycodes.setLayout("ABC")
  -- END HEBREW SUPPORT
  local menuBar = ax.systemElementAtPosition({0, 0}):attributeValue("AXParent")
  for _, v in ipairs(menuBar) do
    if v:attributeValue("AXTitle") == "Help" then
      return v:doPress()
    end
  end
end

function obj.moveFocusToMenuBar()
  ax.systemElementAtPosition({0, 0}):attributeValue("AXParent")[2]:doPress()
end

function obj.rightClick()
  local thisApp = application.frontmostApplication()
  ax.applicationElement(thisApp):focusedUIElement():performAction("AXShowMenu")
end

function obj.notificationCenterToggle()
  local currentMousePos
  -- if panel is shown, toggle between modes
  -- else, open it and click on 'Today'
  if notificationCenterGetPanel() then
    if notificationCenterGetButton(1):attributeValue("AXValue") == 1 then
      notificationCenterGetButton(2):performAction("AXPress")
    else
      notificationCenterGetButton(1):performAction("AXPress")
    end
    return
  end
  currentMousePos = Mouse.getAbsolutePosition()
  local app = ax.applicationElement(application.applicationsForBundleID("com.apple.systemuiserver")[1])
  local menuBarIconPos = ui.getUIElement(app, {{"AXMenuBar", 1}, {"AXMenuBarItem", "AXTitle", "Notification Center"}}):position()
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

function obj.notificationCenterClickButton(theButton)
  local app = application.applicationsForBundleID("com.apple.notificationcenterui")[1]
  local axApp = ax.applicationElement(app)
  local allWindows = axApp:children()
  for i, theWindow in ipairs(allWindows) do
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
        OSAScript.applescript(string.format([[
          ignoring application responses
            tell application "System Events" to tell application process "Notification Center" to tell window %s to click menu button 1
          end ignoring]], i))
        Timer.doAfter(
          0.2,
          function()
            button2:children()[1]:children()[1]:setAttributeValue("AXSelected", true)
          end
        )
      end
    end
  end
end

local function appScriptLauncherChooserCallback(choice)
  getAppActions()[choice.bundleID][choice.text]()
end

local function appScriptLauncher()
  local choices = {}
  local activeAppBundleID = getFrontAppBundleID()
  for id, actionList in pairs(getAppActions()) do
    if activeAppBundleID == id then
      for actionName, _ in pairs(actionList) do
            table.insert(
              choices,
              {
                text = actionName,
                subText = "Application Script",
                image = Image.imageFromAppBundle(activeAppBundleID),
                bundleID = activeAppBundleID,
              }
            )
        end
    end
  end
  GlobalChooser:start(appScriptLauncherChooserCallback, choices, {"text"})
end

local globalHotkeys = {
  -- {"alt", "q", function() appScriptLauncher() end},
  -- {"alt", "e", function() obj.showHelpMenu() end},
  {{"cmd", "shift"}, "1", function() obj.moveFocusToMenuBar() end},
  {hyper, "o", function() obj.rightClick() end},
  {hyper, "1", function() obj.notificationCenterClickButton(1) end},
  {hyper, "2", function() obj.notificationCenterClickButton(2) end},
  {hyper, "3", function() obj.notificationCenterClickButton(3) end},
  {hyper, "n", function() obj.notificationCenterToggle() end},
  {hyper, "l", function() obj.lookUpInDictionary() end},
  -- window manager
  {hyper, "c", function() Window.focusedWindow():centerOnScreen() end},
  {hyper, "down", function() spoon.WindowManager.pushToCell("Down") end},
  {hyper, "left", function() spoon.WindowManager.pushToCell("Left") end},
  {hyper, "return", function() spoon.WindowManager.maximize() end},
  {hyper, "right", function() spoon.WindowManager.pushToCell("Right") end},
  {hyper, "up", function() spoon.WindowManager.pushToCell("Up") end},
  {hyper, "w", function() spoon.WindowManagerModal:start() end},
  {hyper, "m", function() spoon.MouseGrids:start() end},
  {{}, 10, function() spoon.AppWatcher.toggleInputSource() end, nil, nil}
}


function obj:init()
  for _, hotkey in ipairs(globalHotkeys) do
    Hotkey.bind(table.unpack(hotkey))
  end
end

return obj
