local application = require("hs.application")
local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local Mouse = require("hs.mouse")
local Timer = require("hs.timer")
local Hotkey = require("hs.hotkey")
local keycodes = require("hs.keycodes")
local pasteboard = require("hs.pasteboard")
local Window = require("hs.window")
local Task = require("hs.task")
local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")
local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

obj.__index = obj
obj.name = "Globals"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.spoonPath = script_path()

local hyper = {"shift", "cmd", "alt", "ctrl"}
local globalHotkeys = {
  {
    hyper,
    "1",
    function()
      obj.notificationCenterClickButton(1)
    end
  },
  {
    hyper,
    "2",
    function()
      obj.notificationCenterClickButton(2)
    end
  },
  {
    hyper,
    "3",
    function()
      obj.notificationCenterClickButton(3)
    end
  },
  {
    hyper,
    "n",
    function()
      obj.notificationCenterToggle()
    end
  },
  -- window manager
  {
    hyper,
    "w",
    function()
      spoon.WindowManagerModal:start()
    end
  }
}

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

function obj.notificationCenterClickButton(theButton)
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
      --   ignoring application responses
      --   tell application "System Events" to tell application process "Notification Center" to tell window %s to click menu button 1
      --   end ignoring
      end
    end
  end
end

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
end

function obj:init()
  for _, hotkey in ipairs(globalHotkeys) do
    Hotkey.bind(table.unpack(hotkey))
  end
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
