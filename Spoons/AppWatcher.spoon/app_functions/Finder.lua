local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local osascript = require("hs.osascript")
local timer = require("hs.timer")
local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")
local Util = require("rb.util")
local GlobalChooser = require("rb.fuzzychooser")
local FNUtils = require("hs.fnutils")

local next = next

local obj = {}

obj.id = "com.apple.finder"

function obj.browseInLaunchBar()
  osascript.applescript([[
  ignoring application responses
    tell application "LaunchBar" to perform action "Browse Current Folder"
  end ignoring]])
end

function obj.traverseUp()
  osascript.applescript([[
    ignoring application responses
    tell application "LaunchBar" to perform action "Traverse Up"
    end ignoring
  ]])
end

function obj.traverseDown()
  osascript.applescript([[
    ignoring application responses
    tell application "LaunchBar" to perform action "Traverse Down"
    end ignoring
  ]])
end

function obj.browseFolderContents()
  osascript.applescript([[
    ignoring application responses
    tell application "LaunchBar" to perform action "Browse Folder Contents"
    end ignoring
  ]])
end

function obj.getFinderSelection()
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

function obj.getFinderSelectionCount()
  local selection = obj.getFinderSelection()
  if not selection then
    return 0
  end
  local n = 0
  for i, _ in ipairs(selection) do
    n = i
  end
  return n
end

function obj.clickOnRenameMenuItem(appObj)
  local menuItems =
    ui.getUIElement(
    appObj,
    {
      {"AXMenuBar", 1},
      {"AXMenuBarItem", "AXTitle", "File"},
      {"AXMenu", 1}
    }
  ):attributeValue("AXChildren")
  for _, v in ipairs(menuItems) do
    local title = v:attributeValue("AXTitle")
    if string.find(title, "Rename") then
      v:performAction("AXPress")
      return
    end
  end
end

function obj.getMainArea(appObj)
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

function obj.deselectAll(appObj)
  for _, k in ipairs({{"Edit", "Select All"}, {"Edit", "Deselect All"}}) do
    appObj:selectMenuItem(k)
  end
end

function obj.dropboxSmartSyncToggle(syncState)
  local script = [[
    tell application "System Events"
    tell process "Finder"
      tell window 1
        tell toolbar 1
          tell (first group where help contains "Dropbox")
            click menu button 1 -- Dropbox
            delay 0.2
            tell menu 1
              set btn to click menu item "Smart Sync"
              tell btn
                tell menu 1
                  delay 0.1
                  click menu item "%s"
                end tell
              end tell
            end tell
          end tell
        end tell
      end tell
    end tell
  end tell
  ]]
  osascript.applescript(string.format(script, syncState))
end

function obj.rightSizeColumn(appObj, arg)
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

function obj.duplicateTab()
  -- behaves weirdly with a 0.2 (or shorter) delay
  timer.doAfter(
    0.3,
    function()
      osascript.applescript([[
      tell application "Finder" to set _t to target of Finder window 1
      tell application "System Events"
        tell application process "Finder"
          click menu item "New Tab" of menu 1 of menu bar item "File" of menu bar 1
        end tell
      end tell
      tell application "Finder" to set target of Finder window 1 to _t
    ]])
    end
  )
end

function obj.selectColumnChooserCallback(choice)
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

function obj.toggleColumns()
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
      GlobalChooser:start(obj.selectColumnChooserCallback, columnChoices, {"text"})
    end
  )
end

function obj.focusMainArea(appObj)
  -- move focus to files area
  -- scroll area 1 = the common ancestor to all Finder views (list, columns, icons, etc...)
  -- assumption: the files area ui element is different for every view, but it is always to the first child
  obj.getMainArea(appObj):setAttributeValue("AXFocused", true)
  for _ = 1, 3 do
    if obj.getFinderSelection() == nil then
      eventtap.keyStroke({}, "down")
    else
      break
    end
  end
end

function obj.nextSearchScope(appObj)
  local searchScopesBar = {
    {"AXWindow", 1},
    {"AXSplitGroup", 1},
    {"AXGroup", 1},
    {"AXRadioGroup", 1}
  }
  return ui.cycleUIElements(appObj, searchScopesBar, "AXRadioButton", "next")
end

function obj.toggleSortingDirection()
  -- this approach is buggy, returns "name column" even when "date added" is the sort column:
  -- tell application "Finder"
  --	tell list view options of Finder window visible
  --		return name of sort column
  --	end tell
  -- end tell
  osascript.applescript([[
  tell application "System Events"
    tell process "Finder"
      tell menu bar 1 to tell menu bar item "View" to tell menu 1 to tell menu item "Sort By" to tell menu 1
        set theList to value of attribute "AXMenuItemMarkChar" of every menu item
        repeat with i from 1 to count of theList
          if item i of theList = "✓" then
            set theCol to name of menu item i
            exit repeat
          end if
        end repeat
      end tell
      click button theCol of group 1 of outline 1 of scroll area 1 of splitter group 1 of splitter group 1 of window 1
      end tell
    end tell
  end run
  ]])
end

function obj.invertSelection()
  osascript.applescript([[
    tell application "Finder"
    set inverted to {}
    set fitems to items of window 1 as alias list
    set selectedItems to the selection as alias list
    repeat with i in fitems
      if i is not in selectedItems then
        set end of inverted to i
      end if
    end repeat
    select inverted
  end tell
  ]])
end

function obj.undoCloseTab()
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

function obj.clickHistoryToolbarItem(appObj, backOrForward)
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

function obj.isSearchModeActive(appObj)
  local title = appObj:focusedWindow():title()
  if string.match(title, "^Searching “.+”$") then
    -- if search field is focused
    local axApp = ax.applicationElement(appObj)
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return true
    end
  end
end

function obj.moveFocusToFilesAreaIfInSearchMode(appObj, modal)
  if obj.isSearchModeActive(appObj) then
    obj.focusMainArea(appObj)
  else
    modal:exit()
    eventtap.keyStroke({}, "tab")
    modal:enter()
  end
end

function obj.openPackage()
  osascript.applescript(string.format([[
        set f to "%s"
        tell application "Finder"
          if f does not end with "/" then set f to f & "/"
          try
            set target of Finder window 1 to POSIX file (f & "Contents/")
          on error
            set target of Finder window 1 to POSIX file f
          end try
        end tell
      ]], obj.getFinderSelection()[1]))
end

return obj
