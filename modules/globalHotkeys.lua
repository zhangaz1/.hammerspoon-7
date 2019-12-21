local hs = hs
local Hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")
local timer = require("hs.timer")
local pasteboard = require("hs.pasteboard")
local application = require("hs.application")
local ax = require("hs._asm.axuielement")
local keycodes = require("hs.keycodes")
local Window = require("hs.window")

local appScripts = require("modules.appScripts")
local notificationCenter = require("modules.notificationCenter")
local winManager = require("modules.windowManager")

local hyper = {"cmd", "alt", "ctrl", "shift"}

local function lookUpInDictionary()
  eventtap.keyStroke({"cmd"}, "c")
  timer.doAfter(0.4, function()
    local arg = "dict://" .. pasteboard.getContents()
    hs.task.new("/usr/bin/open", nil, {arg}):start()
  end)
end

local function showHelpMenu()
  -- BEGIN HEBREW SUPPORT
  keycodes.setLayout("ABC")
  -- END HEBREW SUPPORT
  local menuBar = ax.systemElementAtPosition({0, 0}):attributeValue("AXParent")
  for _, v in ipairs(menuBar) do if v:attributeValue("AXTitle") == "Help" then return v:doPress() end end
end

local function moveFocusToMenuBar() ax.systemElementAtPosition({0, 0}):attributeValue("AXParent")[2]:doPress() end

local function rightClick()
  local thisApp = application.frontmostApplication()
  ax.applicationElement(thisApp):focusedUIElement():performAction("AXShowMenu")
end

Hotkey.bind(hyper, "l", lookUpInDictionary)
Hotkey.bind({"cmd", "shift"}, "1", moveFocusToMenuBar)
Hotkey.bind({"alt"}, "e", showHelpMenu)
Hotkey.bind(hyper, "o", rightClick)
Hotkey.bind({"alt"}, "q", function() appScripts:start() end)
Hotkey.bind(hyper, "1", function() notificationCenter:clickButton(1) end)
Hotkey.bind(hyper, "2", function() notificationCenter:clickButton(2) end)
Hotkey.bind(hyper, "n", function() notificationCenter:toggle() end)
Hotkey.bind(hyper, "up", function() winManager.pushToCell("Up") end)
Hotkey.bind(hyper, "down", function() winManager.pushToCell("Down") end)
Hotkey.bind(hyper, "right", function() winManager.pushToCell("Right") end)
Hotkey.bind(hyper, "left", function() winManager.pushToCell("Left") end)
Hotkey.bind(hyper, "return", winManager.maximize)
Hotkey.bind(hyper, "c", function() Window.focusedWindow():centerOnScreen() end)
