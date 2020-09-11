--- === Finder ===
---
--- Finder automations.

local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local osascript = require("hs.osascript")
local timer = require("hs.timer")
local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")
local Util = require("rb.util")
local GlobalChooser = require("rb.fuzzychooser")
local FNUtils = require("hs.fnutils")
local Hotkey = require("hs.hotkey")
local next = next

local obj = {}
local _modal = nil
local _appObj = nil

obj.bundleID = "com.apple.finder"

obj.__index = obj
obj.name = "Finder"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function getFinderSelection()
  local _, selection, _ = osascript.applescript([[
    set theSelectionPOSIX to {}
    tell application "Finder" to set theSelection to selection as alias list
    repeat with i from 1 to count theSelection
      set end of theSelectionPOSIX to (POSIX path of item i of theSelection)
    end repeat
    set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {linefeed}}
    return theSelectionPOSIX as text
    set AppleScript's text item delimiters to saveTID
  ]])
  if not selection then
    return
  end
  selection = FNUtils.split(selection, "\n")
  if next(selection) == nil then
    return nil
  else
    return selection
  end
end

local function browseInLaunchBar()
  osascript.applescript([[
  ignoring application responses
    tell application "LaunchBar" to perform action "Browse Current Folder"
  end ignoring]])
end

local function newWindow(modal)
  modal:exit()
  eventtap.keyStroke({"cmd", "alt"}, "n")
  modal:enter()
end

local function rightSizeColumn(appObj, arg)
  -- right-size the first column in list view, or the 'active' column in columns view
  -- for columns view: if arg is "all", right sizes all columns indivdually; if arg is "this", right sizes just the 'focused' column
  -- for list view, arg is ignored and the first column (usually 'name') is resized
  -- if current view is list view, or if current view is columns view (and arg is "this"): double click divider
  -- if currnet view is columns view and arg is "all": double click divider with option down
  -- getting the current view from Finder
  local _, currentView, _ = osascript.applescript('tell application "Finder" to return current view of window 1')
  local axApp = ax.applicationElement(appObj)
  local x, y, coords, modifiers
  -- for columns view:
  -- focusedElement is a selected Finder item, its parent will be the "active" scroll area
  -- we'll get the position of the column-resize icon based on the selected scroll area's AXFrame
  -- each scroll area represents a Finder column (scroll area 1 = column 1...)
  if currentView == "clvw" then
    coords = axApp:focusedUIElement():attributeValue("AXParent"):attributeValue("AXFrame")
    x = (coords.x + coords.w) - 10
    y = (coords.y + coords.h) - 10
  elseif currentView == "lsvw" then
    -- for list view, `arg` is ignored
    arg = "this"
    local firstColumn =
      ui.getUIElement(
      appObj,
      {
        {"AXWindow", 1},
        {"AXSplitGroup", 1},
        {"AXSplitGroup", 1},
        {"AXScrollArea", 1},
        {"AXOutline", 1},
        {"AXGroup", 1},
        {"AXButton", 1}
      }
    )
    coords = firstColumn:attributeValue("AXFrame")
    x = coords.x + coords.w
    y = coords.y + (coords.h / 2)
  end
  local point = geometry.point({x, y})
  if arg == "this" then
    modifiers = nil
  elseif arg == "all" then
    modifiers = {alt = true}
  end
  Util.doubleLeftClick(point, modifiers, true)
end

local function undoCloseTab()
  osascript.applescript(
    [[
    tell application "Default Folder X" to set recentFinderWindows to GetRecentFinderWindows
    tell application "Finder" to set currentFinderWindows to every Finder window
    repeat with i from 1 to count recentFinderWindows
      set recentFinderWindowAsText to (item i of recentFinderWindows as text)
      if not my recentWindowIsCurrentlyOpen(recentFinderWindowAsText, currentFinderWindows) then
        set recentWindowAsPosix to POSIX path of item i of recentFinderWindows
        return do shell script "/usr/bin/open" & space & quoted form of recentWindowAsPosix
      end if
    end repeat

    on recentWindowIsCurrentlyOpen(recentFinderWindowAsText, currentFinderWindows)
      tell application "Finder"
        -- skip non existent items
        if not (exists alias recentFinderWindowAsText) then return true
        repeat with i from 1 to count currentFinderWindows
          set currentFinderWindow to item i of currentFinderWindows
          set currentFinderWindowAsAlias to (target of currentFinderWindow as alias)
          set currentFinderWindowAsText to (currentFinderWindowAsAlias as text)
          -- if tab is open but not the first tab, switch to it
          if recentFinderWindowAsText = currentFinderWindowAsText then
            return true
          end if
        end repeat
        return false
      end tell
    end recentWindowIsCurrentlyOpen
  ]]
  )
end

local function getMainArea(appObj)
  -- the last common ancestors to all finder views
  local mainArea =
    ui.getUIElement(
    appObj,
    {
      {"AXWindow", 1},
      {"AXSplitGroup", 1},
      {"AXSplitGroup", 1}
    }
  )
  -- column view: axbrowser 1; axscrollarea 1 for icon, list and gallery
  if mainArea then
    return mainArea:children()[1]
  end
end

local function focusMainArea(appObj)
  -- move focus to files area
  -- scroll area 1 = the common ancestor to all Finder views (list, columns, icons, etc...)
  -- assumption: the files area ui element is different for every view, but it is always to the first child
  getMainArea(appObj):setAttributeValue("AXFocused", true)
  for _ = 1, 3 do
    if getFinderSelection() == nil then
      eventtap.keyStroke({}, "down")
    else
      break
    end
  end
end

local function isSearchModeActive(appObj)
  local title = appObj:focusedWindow():title()
  if string.match(title, "^Searching “.+”$") then
    -- if search field is focused
    local axApp = ax.applicationElement(appObj)
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return true
    end
  end
end

local function moveFocusToFilesAreaIfInSearchMode(appObj, modal)
  if isSearchModeActive(appObj) then
    focusMainArea(appObj)
  else
    modal:exit()
    eventtap.keyStroke({}, "tab")
    modal:enter()
  end
end

local function openPackage()
  osascript.applescript([[
    tell application "Finder"
    set theSelection to selection
    set thePaths to {}
    repeat with i from 1 to count theSelection
      set theSelected to item i of theSelection
      try
        set theTarget to folder "Contents" of theSelected
      on error
        set theTarget to theSelected
      end try
      set end of thePaths to theTarget
    end repeat
    if (count of thePaths) is 1 then
      set target of Finder window 1 to (item 1 of thePaths)
      return
    end if
    if (count of thePaths) > 1 then
      open thePaths as alias list
    end if
  end tell]])
end

local function deselectAll(appObj)
  for _, k in ipairs({{"Edit", "Select All"}, {"Edit", "Deselect All"}}) do
    appObj:selectMenuItem(k)
  end
end

local function toggleColumns()
  local function selectColumnChooserCallback(choice)
    osascript.applescript([[
      tell application "System Events"
      tell process "Finder"
        click menu item "Show View Options" of menu 1 of menu bar item "View" of menu bar 1
        delay 2
        tell window 1
          tell group 1
            click checkbox "]] .. choice.text .. [["
          end tell
          click button 2
        end tell
      end tell
    end tell
    ]])
  end
  local columnChoices = {}
  local columns = {
    "iCloud Status",
    "Date Modified",
    "Date Created",
    "Date Last Opened",
    "Date Added",
    "Size",
    "Kind",
    "Version",
    "Comments",
    "Tags"
  }
  for _, col in ipairs(columns) do
    table.insert(columnChoices, {["text"] = col})
  end
  timer.doAfter(
    0.1,
    function()
      GlobalChooser:start(selectColumnChooserCallback, columnChoices, {"text"})
    end
  )
end

local function clickHistoryToolbarItem(appObj, backOrForward)
  local button
  if backOrForward == "back" then
    button = 1
  elseif backOrForward == "forward" then
    button = 2
  else
    return
  end
  ui.getUIElement(
    ax.windowElement(appObj:mainWindow()),
    {
      {"AXToolbar", 1},
      {"AXGroup", 1},
      {"AXGroup", 1},
      {"AXButton", button}
    }
  ):performAction("AXShowMenu")
end

local hotkeys = {
  {
    "alt",
    "f",
    function()
      browseInLaunchBar()
    end
  },
  {
    "alt",
    "2",
    function()
      focusMainArea(_appObj)
    end
  },
  {
    "cmd",
    "n",
    function()
      newWindow(_modal)
    end
  },
  {
    {"shift", "cmd"},
    "t",
    function()
      undoCloseTab()
    end
  },
  {
    {},
    "tab",
    function()
      moveFocusToFilesAreaIfInSearchMode(_appObj, _modal)
    end
  },
  -- TODO: remove?
  {
    {"shift", "cmd"},
    "up",
    function()
      _appObj:selectMenuItem({"File", "Show Original"})
    end
  },
  {
    {"shift", "cmd"},
    "down",
    function()
      _appObj:selectMenuItem({"File", "Open in New Tab"})
    end
  },
  {
    "alt",
    "o",
    function()
      openPackage()
    end
  },
  {
    {"alt", "shift"},
    "r",
    function()
      rightSizeColumn(_appObj, "all")
    end
  },
  {
    "alt",
    "r",
    function()
      rightSizeColumn(_appObj, "this")
    end
  }
}

function obj:start(appObj)
  _appObj = appObj
  _modal:enter()
end

function obj:stop()
  _modal:exit()
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

-- local function getFinderSelectionCount()
--   local selection = getFinderSelection()
--   if not selection then
--     return 0
--   end
--   local n = 0
--   for i, _ in ipairs(selection) do
--     n = i
--   end
--   return n
-- end

-- local function nextSearchScope(appObj)
--   local searchScopesBar = {
--     {"AXWindow", 1},
--     {"AXSplitGroup", 1},
--     {"AXGroup", 1},
--     {"AXRadioGroup", 1}
--   }
--   return ui.cycleUIElements(appObj, searchScopesBar, "AXRadioButton", "next")
-- end