--- === Safari ===
---
--- Safari automations.
---

local EventTap = require("hs.eventtap")
local AppleScript = require("hs.osascript").applescript
local KeyCodes = require("hs.keycodes")
local Timer = require("hs.timer")
local Hotkey = require("hs.hotkey")
local FnUtils = require("hs.fnutils")
local Settings = require("hs.settings")
local UI = require("rb.ui")
local Util = require("rb.util")
local AX = require("hs._asm.axuielement")
local Observer = AX.observer

local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

obj.__index = obj
obj.name = "Safari"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "com.apple.Safari"

local _modal = nil
local _appObj = nil
local _observer = nil
local layoutsPerURLKey = "RBSafariLayoutsForURL"

local function moveFocusToSafariMainArea(appObj, includeSidebar)
  -- ui scripting notes:
  -- when the statusbar overlay shows, it's the first window. you should look for the "Main" window instread.
  -- "pane1" = is either the main web area, or the sidebar
  local UIElementSidebar = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
  local UIElementPane1BookmarksHistoryView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
  local UIElementPane1StandardView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXWebArea", 1}}
  local targetPane
  local sideBar
  local webArea = UI.getUIElement(appObj, UIElementPane1StandardView)
  local bookmarksOrHistory = UI.getUIElement(appObj, UIElementPane1BookmarksHistoryView)
  if includeSidebar then
    sideBar = UI.getUIElement(appObj, UIElementSidebar)
  end
  if sideBar then
    targetPane = sideBar
  elseif webArea then
    targetPane = webArea
  elseif bookmarksOrHistory then
    targetPane = bookmarksOrHistory
  end
  targetPane:setAttributeValue("AXFocused", true)
end

local function isSafariAddressBarFocused(appObj)
  local axAppObj = AX.applicationElement(appObj)
  local addressBarObject = UI.getUIElement(axAppObj, {{"AXWindow", "AXMain", true}, {"AXToolbar", 1}}):attributeValue("AXChildren")
  for _, toolbarObject in ipairs(addressBarObject) do
    local toolbarObjectsChilds = toolbarObject:attributeValue("AXChildren")
    if toolbarObjectsChilds then
      for _, toolbarObjectChild in ipairs(toolbarObjectsChilds) do
        if toolbarObjectChild:attributeValue("AXRole") == "AXTextField" then
          return (toolbarObjectChild:attributeValue("AXFocused") == true)
        end
      end
    end
  end
end

local function changeToABCAfterFocusingAddressBar(modal, keystroke)
  if KeyCodes.currentLayout() == "Hebrew" then
    KeyCodes.setLayout("ABC")
  end
  modal:exit()
  EventTap.keyStroke(table.unpack(keystroke))
  modal:enter()
end

local function moveFocusToMainAreaAfterOpeningLocation(appObj, modal, keystroke)
  local UIElementHomeScreenView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXScrollArea", 1}}
  if isSafariAddressBarFocused(appObj) then
    KeyCodes.setLayout("ABC")
  end
  modal:exit()
  EventTap.keyStroke(table.unpack(keystroke))
  modal:enter()
  Timer.doAfter(
    0.2,
    function()
      if isSafariAddressBarFocused(appObj) then
        for _ = 1, 5 do
          Timer.doAfter(
            0.5,
            function()
              local safariStartPage = UI.getUIElement(appObj, UIElementHomeScreenView)
              if not safariStartPage then
                moveFocusToSafariMainArea(appObj, true)
                return
              end
            end
          )
        end
      end
    end
  )
end

local function pageNavigation(direction)
  local jsFile = script_path() .. "/navigatePages.js"
  local script = [[
    set _arg to "%s"
    set theFile to (POSIX file "%s" as alias)
    set theScript to read theFile as string
    set theScript to "var direction = '" & _arg & "'; " & theScript
    tell application "Safari"
	  tell (window 1 whose visible of it = true)
		  tell (tab 1 whose visible of it = true)
			  return do JavaScript theScript
		  end tell
	  end tell
    end tell
  ]]
  script = string.format(script, direction, jsFile)
  AppleScript(script)
end

local function goToFirstInputField()
  local jsFile = script_path() .. "/goToFirstInputField.js"
  local script = [[
    set theFile to (POSIX file "%s" as alias)
    set theScript to read theFile as string
    tell application "Safari"
	  tell (window 1 whose visible of it = true)
		  tell (tab 1 whose visible of it = true)
			  return do JavaScript theScript
		  end tell
	  end tell
    end tell
  ]]
  script = string.format(script, jsFile)
  AppleScript(script)
end

local function newBookmarksFolder(appObj)
  local title = appObj:focusedWindow():title()
  if string.match(title, "Bookmarks") then
    UI.getUIElement(appObj, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXButton", 1}}):performAction("AXPress")
  else
    appObj:selectMenuItem({"File", "New Private Window"})
  end
end

local function rightSizeBookmarksOrHistoryColumn(appObj)
  local firstColumn =
    UI.getUIElement(
    appObj,
    {
      {"AXWindow", 1},
      {"AXSplitGroup", 1},
      {"AXTabGroup", 1},
      {"AXGroup", 1},
      {"AXScrollArea", 1},
      {"AXOutline", 1},
      {"AXGroup", 1},
      {"AXButton", "AXTitle", "Website"}
    }
  ):attributeValue("AXFrame")
  local x = firstColumn.x + firstColumn.w
  local y = firstColumn.y + 5
  Util.doubleLeftClick({x, y})
end

local function firstSearchResult(appObj, modal)
  -- moves focus to the bookmarks/history list
  local title = appObj:focusedWindow():title()
  -- if we're in the history or bookmarks windows
  if title:match("Bookmarks") or title:match("History") then
    local axApp = AX.applicationElement(appObj)
    -- if search field is focused
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return moveFocusToSafariMainArea(appObj, false)
    end
  end
  modal:exit()
  EventTap.keyStroke({}, "tab")
  modal:enter()
end

local function moveTab(direction)
  local args
  if direction == "right" then
    args = {"+", "1", "before", "after"}
  else
    args = {"-", "(index of last tab)", "after", "before"}
  end
  local script = [[
    tell application "Safari"
    tell window 1
      set sourceIndex to index of current tab
      set targetIndex to (sourceIndex %s 1)
      if not (exists tab targetIndex) then
        set targetIndex to %s
        move tab sourceIndex to %s tab targetIndex
      end if
      move tab sourceIndex to %s tab targetIndex
      set current tab to tab targetIndex
    end tell
  end tell
  ]]
  script = string.format(script, table.unpack(args))
  AppleScript(script)
end

local function getCurrentURL()
  -- applescript method
  local _, currentURL, _ = AppleScript([[
    tell application "Safari"
      tell window 1
        return URL of current tab
      end tell
    end tell
    ]])
  if not currentURL then
    return
  end
  -- print("Safari: current URL: " .. currentURL)
  for _, v in ipairs(FnUtils.split(currentURL, "/")) do
    if v and string.find(v, "%.") then
      currentURL = v
      break
    end
  end
  return currentURL
end

local function setLayoutForURL(_, _, _, _)
  local url = getCurrentURL()
  local special = {"bookmarks://", "history://", "favorites://"}
  if not url or FnUtils.contains(special, url) then
    KeyCodes.setLayout("ABC")
    return
  end
  local newLayout = "ABC"
  local settingsTable = Settings.get(layoutsPerURLKey) or {}
  local urlSetting = settingsTable[url]
  if urlSetting then
    newLayout = urlSetting
  end
  KeyCodes.setLayout(newLayout)
end

local function addObserver(appObj)
  local pid = appObj:pid()
  _observer = Observer.new(pid)
  local element = AX.applicationElement(appObj)
  _observer:addWatcher(element, "AXTitleChanged")
  _observer:callback(setLayoutForURL)
  _observer:start()
  setLayoutForURL()
end

local hotkeys = {
  {
    "ctrl",
    ",",
    function()
      moveTab("left")
    end
  },
  {
    "ctrl",
    ".",
    function()
      moveTab("right")
    end
  },
  {
    "cmd",
    "n",
    function()
      _appObj:selectMenuItem({"File", "New Window"})
    end
  },
  {
    "ctrl",
    "i",
    function()
      goToFirstInputField()
    end
  },
  {
    "ctrl",
    "n",
    function()
      pageNavigation("next")
    end
  },
  {
    "ctrl",
    "p",
    function()
      pageNavigation("previous")
    end
  },
  {
    {},
    "return",
    function()
      moveFocusToMainAreaAfterOpeningLocation(_appObj, _modal, {{}, "return"})
    end
  },
  {
    {"cmd"},
    "l",
    function()
      changeToABCAfterFocusingAddressBar(_modal, {{"cmd"}, "l"})
    end
  },
  {
    "alt",
    "1",
    function()
      moveFocusToSafariMainArea(_appObj, true)
    end
  },
  {
    "alt",
    "2",
    function()
      moveFocusToSafariMainArea(_appObj, false)
    end
  },
  {
    {"cmd", "shift"},
    "n",
    function()
      newBookmarksFolder(_appObj)
    end
  },
  {
    "alt",
    "r",
    function()
      rightSizeBookmarksOrHistoryColumn(_appObj)
    end
  },
  {
    {},
    "tab",
    function()
      firstSearchResult(_appObj, _modal)
    end
  }
}

function obj:saveLayoutForCurrentURL(newLayout)
  local settingsTable = Settings.get(layoutsPerURLKey) or {}
  local currentURL = getCurrentURL()
  settingsTable[currentURL] = newLayout
  Settings.set(layoutsPerURLKey, settingsTable)
end

function obj:start(appObj)
  _appObj = appObj
  _modal:enter()
  addObserver(appObj)
end

function obj:stop()
  _modal:exit()
  if _observer then
    _observer:stop()
    _observer = nil
  end
end

function obj:init()
  if not obj.bundleID then
    hs.showError("bundle indetifier for app spoon is nil")
  end
  _modal = Hotkey.modal.new()
  for _, v in ipairs(hotkeys) do
    _modal:bind(table.unpack(v))
  end
end

return obj

-- local function showNavMenus(appObj, direction)
--   local button
--   if direction == "forward" then
--     button = 2
--   else
--     button = 1
--   end
--   UI.getUIElement(appObj:mainWindow(), {{"AXToolbar", 1}, {"AXGroup", 1}, {"AXButton", button}}):performAction("AXShowMenu")
-- end

-- local function savePageAsPDF()
--   AppleScript([[
--     tell application "System Events"
--       tell process "Safari"
--         tell menu bar 1
--           tell menu bar item "File"
--             tell menu 1
--               click (first menu item whose title contains "Print")
--             end tell
--           end tell
--         end tell
--         tell window 1
--           repeat until sheet 1 exists
--           end repeat
--           tell sheet 1
--             click menu button 1 -- "PDF"
--             delay 0.2
--             tell menu button 1
--               tell menu 1
--                 click menu item "Save as PDF"
--               end tell
--             end tell
--           end tell
--         end tell
--       end tell
--     end tell]])
-- end
