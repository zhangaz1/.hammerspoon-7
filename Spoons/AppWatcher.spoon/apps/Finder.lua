local eventtap = require("hs.eventtap")
local geometry = require("hs.geometry")
local hotkey = require("hs.hotkey")
local keycodes = require("hs.keycodes")
local osascript = require("hs.osascript")
local timer = require("hs.timer")

local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")
local Util = require("rb.util")
local GlobalChooser = require("rb.fuzzychooser")
local pressAndHold = require("rb.pressandhold")

local keyboard = {["]"] = keycodes.map["]"], ["["] = keycodes.map["["]}

local obj = {}

obj.id = "com.apple.finder"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

local function getMainArea()
  -- the last common ancestors to all finder views
  local mainArea =
    ui.getUIElement(
    obj.thisApp,
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

---

local function deselectAll()
  for _, k in ipairs({{"Edit", "Select All"}, {"Edit", "Deselect All"}}) do
    obj.thisApp:selectMenuItem(k)
  end
end

local function dropboxSmartSyncToggle(syncState)
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

local function rightSizeColumn(arg)
  -- right-size the first column in list view, or the 'active' column in columns view
  -- for columns view: if arg is "all", right sizes all columns indivdually; if arg is "this",
  -- right sizes the 'focused' column individually
  -- for list view, arg is ignored and the first column (usually 'name') is resized
  -- if current view is list view, or if current view is columns view (and arg is "this"): double click divider
  -- if currnet view is columns view and arg is "all": double click divider with option down
  -- get current view from Finder
  local _, currentView, _ = osascript.applescript('tell application "Finder" to return current view of window 1')
  local axApp = ax.applicationElement(obj.thisApp)
  local x
  local y
  local coords
  -- columns view
  if currentView == "clvw" then
    -- list view
    -- focusedElement is a selected Finder item, its parent will be the "active" scroll area
    -- we'll get the position of the column-resize icon based on the selected scroll area's AXFrame
    -- each scroll area represents a Finder column (scroll area 1 = column 1...)
    coords = axApp:focusedUIElement():attributeValue("AXParent"):attributeValue("AXFrame")
    x = (coords.x + coords.w) - 10
    y = (coords.y + coords.h) - 10
  elseif currentView == "lsvw" then
    -- arg is ignored for list view
    arg = "this"
    local firstColumn =
      ui.getUIElement(
      obj.thisApp,
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
    Util.doubleLeftClick(point)
  elseif arg == "all" then
    Util.doubleLeftClick(point, {alt = true})
  end
end

local function browseInLaunchBar()
  osascript.applescript([[
  ignoring application responses
    tell application "LaunchBar" to perform action "Browse Current Folder"
  end ignoring]])
end

local function duplicateTab()
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

local function toggleColumns()
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

local function focusMainArea()
  -- move focus to files area
  -- scroll area 1 = the common ancestor to all Finder views (list, columns, icons, etc...)
  -- assumption: the files area ui element is different for every view, but it is always to the first child
  getMainArea():setAttributeValue("AXFocused", true)
  for _ = 1, 3 do
    if Util.getFinderSelection() == nil then
      eventtap.keyStroke({}, "down")
    else
      break
    end
  end
end

local function nextSearchScope()
  local searchScopesBar = {
    {"AXWindow", 1},
    {"AXSplitGroup", 1},
    {"AXGroup", 1},
    {"AXRadioGroup", 1}
  }
  return ui.cycleUIElements(obj.thisApp, searchScopesBar, "AXRadioButton", "next")
end

local function toggleSortingDirection()
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

local function invertSelection()
  -- task.new("util/finder-invert-selection/cli.js", nil):start()
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
        --	skip non existent items
        if not (exists alias recentFinderWindowAsText) then return true
        repeat with i from 1 to count currentFinderWindows
          set currentFinderWindow to item i of currentFinderWindows
          set currentFinderWindowAsAlias to (target of currentFinderWindow as alias)
          set currentFinderWindowAsText to (currentFinderWindowAsAlias as text)
          --if tab is open but not the first tab, switch to it
          --if index of currentFinderWindow = 1 then
          --end if
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

local function showNavPopup(backOrForward)
  local button
  if backOrForward == "back" then
    button = 1
  elseif backOrForward == "forward" then
    button = 2
  else
    error()
  end
  ui.getUIElement(
    ax.windowElement(obj.thisApp:mainWindow()),
    {
      {"AXToolbar", 1},
      {"AXGroup", 1},
      {"AXGroup", 1},
      {"AXButton", button}
    }
  ):performAction("AXShowMenu")
end

local function showBackMenu()
  showNavPopup("back")
end

local function showForwardMenu()
  showNavPopup("forward")
end

local function traverseUp()
  osascript.applescript([[
    ignoring application responses
    tell application "LaunchBar" to perform action "Traverse Up"
    end ignoring
  ]])
end

local function traverseDown()
  osascript.applescript([[
    ignoring application responses
    tell application "LaunchBar" to perform action "Traverse Down"
    end ignoring
  ]])
end

local function browseFolderContents()
  osascript.applescript([[
    ignoring application responses
    tell application "LaunchBar" to perform action "Browse Folder Contents"
    end ignoring
  ]])
end

local function isSearchModeActive()
  local title = obj.thisApp:focusedWindow():title()
  if string.match(title, "^Searching “.+”$") then
    -- if search field is focused
    local axApp = ax.applicationElement(obj.thisApp)
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return true
    end
  end
end

local function openPackage()
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
      ]], Util.getFinderSelection()[1]))
end

obj.modal:bind({"alt", "cmd"}, "a", deselectAll)
obj.modal:bind({"alt", "cmd"}, "down", browseFolderContents)
obj.modal:bind({"alt"}, "2", focusMainArea)
obj.modal:bind({"alt"}, "f", browseInLaunchBar)
obj.modal:bind({"alt"}, "o", openPackage)
obj.modal:bind({"shift", "cmd"}, "t", undoCloseTab)

obj.modal:bind(
  {"alt", "cmd"},
  "left",
  function()
    obj.thisApp:selectMenuItem({"Window", "Show Previous Tab"})
  end
)
obj.modal:bind(
  {"alt", "cmd"},
  "right",
  function()
    obj.thisApp:selectMenuItem({"Window", "Show Next Tab"})
  end
)
obj.modal:bind(
  {"alt", "shift"},
  "r",
  function()
    rightSizeColumn("all")
  end
)
obj.modal:bind(
  {"alt"},
  "r",
  function()
    rightSizeColumn("this")
  end
)
obj.modal:bind(
  {"cmd"},
  "n",
  nil,
  function()
    Util.strictShortcut(
      {{"cmd"}, "n"},
      obj.thisApp,
      obj.modal,
      nil,
      function()
        eventtap.keyStroke({"cmd", "alt"}, "n")
      end
    )
  end,
  nil
)
obj.modal:bind(
  {"shift", "cmd"},
  "down",
  function()
    obj.thisApp:selectMenuItem({"File", "Open in New Tab"})
  end
)
obj.modal:bind(
  {"shift", "cmd"},
  "up",
  function()
    obj.thisApp:selectMenuItem({"File", "Show Original"})
  end
)

obj.modal:bind(
  {"cmd"},
  keyboard["["],
  function()
    pressAndHold.onHold(0.2, showBackMenu)
  end,
  function()
    pressAndHold.onPress(
      function()
        obj.modal:exit()
        eventtap.keyStroke({"cmd"}, keyboard["["])
        obj.modal:enter()
      end
    )
  end
)
obj.modal:bind(
  {"cmd"},
  keyboard["]"],
  function()
    pressAndHold.onHold(0.2, showForwardMenu)
  end,
  function()
    pressAndHold.onPress(
      function()
        obj.modal:exit()
        eventtap.keyStroke({"cmd"}, keyboard["]"])
        obj.modal:enter()
      end
    )
  end
)
obj.modal:bind(
  {"cmd"},
  "up",
  function()
    pressAndHold.onHold(0.2, traverseUp)
  end,
  function()
    pressAndHold.onPress(
      function()
        obj.modal:exit()
        eventtap.keyStroke({"cmd"}, "up")
        obj.modal:enter()
      end
    )
  end
)
obj.modal:bind(
  {"cmd"},
  "down",
  function()
    if isSearchModeActive() then
      return focusMainArea()
    end
    pressAndHold.onHold(0.2, traverseDown)
  end,
  function()
    if isSearchModeActive() then
      return focusMainArea()
    end
    pressAndHold.onPress(
      function()
        obj.modal:exit()
        eventtap.keyStroke({"cmd"}, "down")
        obj.modal:enter()
      end
    )
  end
)

obj.appScripts = {
  {
    title = "Toggle Columns",
    func = function()
      toggleColumns()
    end
  },
  {
    title = "Toggle Sort Direction",
    func = function()
      toggleSortingDirection()
    end
  },
  {
    title = "Dropbox Smart Sync: Local",
    func = function()
      dropboxSmartSyncToggle("Local")
    end
  },
  {
    title = "Dropbox Smart Sync: Online Only",
    func = function()
      dropboxSmartSyncToggle("Online Only")
    end
  },
  {
    title = "Duplicate Tab",
    func = function()
      duplicateTab()
    end
  },
  {
    title = "Deselect All",
    func = function()
      deselectAll()
    end
  },
  {
    title = "Next Search Scope",
    func = function()
      nextSearchScope()
    end
  },
  {
    title = "Invert Selection",
    func = function()
      invertSelection()
    end
  }
}

return obj
