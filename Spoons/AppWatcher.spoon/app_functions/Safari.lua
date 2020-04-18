local EventTap = require("hs.eventtap")
local AppleScript = require("hs.osascript").applescript
local UI = require("rb.ui")
local AX = require("hs._asm.axuielement")
local Util = require("rb.util")
local KeyCodes = require("hs.keycodes")
local Timer = require("hs.timer")

local obj = {}

obj.id = "com.apple.Safari"

local function helpersPath()
  return spoon.AppWatcher.helpers
end

-- the statusbar overlay is AXWindow 1!
-- pane1 = is either the main web area, or the sidebar
local UIElementSidebar = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
local UIElementPane1BookmarksHistoryView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
local UIElementPane1StandardView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXWebArea", 1}}
local UIElementHomeScreenView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXScrollArea", 1}}

function obj.inputWatcherInvokedMoveFocusToMainAreaAfterOpeningLocation(appObj)
  if obj.isSafariAddressBarFocused(appObj) then
    KeyCodes.setLayout("ABC")
  end
  Timer.doAfter(
    0.2,
    function()
      if obj.isSafariAddressBarFocused(appObj) then
        for _ = 1, 5 do
          Timer.doAfter(
            0.5,
            function()
              local safariStartPage = UI.getUIElement(appObj, UIElementHomeScreenView)
              if not safariStartPage then
                obj.moveFocusToSafariMainArea(appObj, true)
                return
              end
            end
          )
        end
      end
    end
  )
end

function obj.moveFocusToMainAreaAfterOpeningLocation(modal, keystroke, appObj)
  if obj.isSafariAddressBarFocused(appObj) then
    KeyCodes.setLayout("ABC")
  end
  modal:exit()
  EventTap.keyStroke(table.unpack(keystroke))
  modal:enter()
  Timer.doAfter(
    0.2,
    function()
      if obj.isSafariAddressBarFocused(appObj) then
        for _ = 1, 5 do
          Timer.doAfter(
            0.5,
            function()
              local safariStartPage = UI.getUIElement(appObj, UIElementHomeScreenView)
              if not safariStartPage then
                obj.moveFocusToSafariMainArea(appObj, true)
                return
              end
            end
          )
        end
      end
    end
  )
end

function obj.isSafariAddressBarFocused(appObj)
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


function obj.pageNavigation(direction)
  local jsFile = helpersPath() .. "/navigatePages.js"
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

function obj.goToFirstInputField()
  local jsFile = helpersPath() .. "/goToFirstInputField.js"
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

function obj.moveFocusToSafariMainArea(appObj, includeSidebar)
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

function obj.closeTabsToDirection(direction)
  AppleScript(string.format([[
      set arg to "%s"
      tell application "Safari"
        tell window 1
          --	get visible tab
          set visibleTab to index of first tab whose visible is true
          -- assign tabToClose to the tab that's on the immediate right
          if arg = "right" then
            set tabToClose to first tab whose index = visibleTab + 1
            repeat while tabToClose exists
              close tabToClose
            end repeat
            -- close the visible  tab until i becomes 1:
            -- in practice making that visible tab, the first tab
          else if arg = "left" then
            repeat until visibleTab = 1
              close tab index 1
              set visibleTab to visibleTab - 1
            end repeat
          end if
        end tell
      end tell]], direction))
end

function obj.clickOnTranslateMeMenuButton()
  AppleScript([[
    tell application "System Events"
      tell process "Safari"
        tell window 1
          tell toolbar 1
            set groupList to (description of every button of every UI element of every group)
            repeat with g from 1 to (count groupList)
              set UIElementList to item g of groupList
                repeat with u from 1 to (count UIElementList)
                  set buttonDescriptionList to item u of UIElementList
                  repeat with b from 1 to (count buttonDescriptionList)
                    if (item b of buttonDescriptionList is "TranslateMe") then
                      return perform action "AXPress" of button b of UI element u of group g
                    end if
                  end repeat
                end repeat
              end repeat
            end tell
          end tell
        end tell
    end tell]])
end

function obj.openThisTabInChrome()
  AppleScript([[
    tell application "Safari"
      tell its first window
        set _url to URL of its first tab where it is visible
        set _url to _url as text
      end tell
    end tell
    tell application "Google Chrome"
      activate
      repeat until its first window exists
      end repeat
      tell its first window
        set _tab to make new tab
        set URL of _tab to _url
      end tell
    end tell]])
end

function obj.savePageAsPDF()
  AppleScript([[
    tell application "System Events"
      tell process "Safari"
        tell menu bar 1
          tell menu bar item "File"
            tell menu 1
              click (first menu item whose title contains "Print")
            end tell
          end tell
        end tell
        tell window 1
          repeat until sheet 1 exists
          end repeat
          tell sheet 1
            click menu button 1 -- "PDF"
            delay 0.2
            tell menu button 1
              tell menu 1
                click menu item "Save as PDF"
              end tell
            end tell
          end tell
        end tell
      end tell
    end tell]])
end

function obj.newBookmarksFolder(appObj)
  local title = appObj:focusedWindow():title()
  if string.match(title, "Bookmarks") then
    UI.getUIElement(appObj, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXButton", 1}}):performAction("AXPress")
  else
    appObj:selectMenuItem({"File", "New Private Window"})
  end
end

function obj.newInvoiceForCurrentIcountCustomer()
  local _, url, _ = AppleScript('tell application "Safari" to tell window 1 to return URL of current tab')
  url = url:match("id=(%d+)")
  AppleScript(string.format([[
  tell application "Safari"
    tell window 1
      tell current tab
        set URL to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=%s"
      end tell
    end tell
  end tell
  ]], url))
end

function obj.rightSizeBookmarksOrHistoryColumn(appObj)
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

function obj.duplicateTab()
  AppleScript([[
    tell application "Safari"
    tell window 1
      tell current tab
        set _u to its URL
        set _i to its index
      end tell
      set newTab to make new tab at after tab (_i)
      set URL of newTab to _u
    end tell
  end tell
  ]])
end

function obj.openAsPrivateTab()
  AppleScript([[
    tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
    tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
    tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
  ]])
end

function obj.switchTab(appObj, direction)
  appObj:selectMenuItem({"Window", direction})
end

function obj.showNavMenus(appObj, direction)
  local button
  if direction == "forward" then
    button = 2
  else
    button = 1
  end
  UI.getUIElement(appObj:mainWindow(), {{"AXToolbar", 1}, {"AXGroup", 1}, {"AXButton", button}}):performAction("AXShowMenu")
end

function obj.getText()
  AppleScript([[
    ignoring application responses
      tell application "LaunchBar" to perform action "Safari: Get Text"
    end ignoring]])
end

function obj.firstSearchResult(appObj, modal)
  -- moves focus to the bookmarks/history list
  local title = appObj:focusedWindow():title()
  -- if we're in the history or bookmarks windows
  if title:match("Bookmarks") or title:match("History") then
    local axApp = AX.applicationElement(appObj)
    -- if search field is focused
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return obj.moveFocusToSafariMainArea(appObj, false)
    end
  end
  modal:exit()
  EventTap.keyStroke({}, "tab")
  modal:enter()
end

function obj.moveTab(direction)
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

return obj
