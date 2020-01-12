local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")

local ax = require("hs._asm.axuielement")

local Util = require("rb.util")
local ui = require("rb.ui")
local pressAndHold = require("rb.pressandhold")

local keyboard = {["]"] = keycodes.map["]"], ["["] = keycodes.map["["]}

local obj = {}

obj.id = "com.apple.Safari"
obj.thisApp = nil
obj.modal = hotkey.modal.new()
obj.safariPid = nil
obj.safariAXObserver = nil
obj.safariAXAppObj = nil

---

local function closeTabs(arg)
  osascript.applescript(string.format([[
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
    end tell]], arg))
end

local function translate()
  osascript.applescript([[
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

local function openTabInChrome()
  osascript.applescript([[
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

local function savePageAsPDF()
  osascript.applescript([[
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

local function newBookmarksFolder()
  local title
  title = obj.thisApp:focusedWindow():title()
  if string.match(title, "Bookmarks") then
    ui.getUIElement(obj.thisApp, {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXButton", 1}}):performAction("AXPress")
  else
    obj.modal:exit()
    eventtap.keyStroke({"shift", "cmd"}, "n")
    obj.modal:enter()
  end
end

local function newInvoiceForCurrentIcountCustomer()
  local _, url, _ = osascript.applescript('tell application "Safari" to tell window 1 to return URL of current tab')
  url = url:match("id=(%d+)")
  osascript.applescript(string.format([[
  tell application "Safari"
    tell window 1
      tell current tab
        set URL to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=%s"
      end tell
    end tell
  end tell
  ]], url))
end

local function rightSizeBookmarksOrHistoryColumn()
  local firstColumn =
    ui.getUIElement(
    obj.thisApp,
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

local function duplicateTab()
  eventtap.keyStroke({"cmd"}, "l")
  eventtap.keyStroke({"cmd"}, "return")
  eventtap.keyStroke({"ctrl"}, "tab")
end

local function openAsPrivateTab()
  osascript.applescript([[
    tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
    tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
    tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
  ]])
end

local function firstSearchResult()
  -- moves focus to the bookmarks/history list
  local title = obj.thisApp:focusedWindow():title()
  -- if we're in the history or bookmarks windows
  if title:match("Bookmarks") or title:match("History") then
    local axApp = ax.applicationElement(obj.thisApp)
    -- if search field is focused
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return Util.moveFocusToSafariMainArea(obj.thisApp, false)
    end
  end
  -- otherwise...
  obj.modal:exit()
  eventtap.keyStroke({"cmd"}, "down")
  obj.modal:enter()
end

local function switchTab(direction)
  obj.thisApp:selectMenuItem({"Window", direction})
end

local function showNavMenus(backOrForward)
  local button
  if backOrForward == "forward" then
    button = 2
  else
    button = 1
  end
  ui.getUIElement(obj.thisApp:mainWindow(), {{"AXToolbar", 1}, {"AXGroup", 1}, {"AXButton", button}}):performAction("AXShowMenu")
end

local function showBackMenu()
  showNavMenus("back")
end

local function showForwardMenu()
  showNavMenus("forward")
end

local function getText()
  osascript.applescript([[
    ignoring application responses
      tell application "LaunchBar" to perform action "Safari: Get Text"
    end ignoring]])
end

obj.modal:bind({"ctrl"}, "n", function() spoon.SafariNavigatePages.nextPage() end)
obj.modal:bind({"ctrl"}, "p", function() spoon.SafariNavigatePages.prevPage() end)
obj.modal:bind({"ctrl"}, "i", function() spoon.SafariGoToFirstInputField:start() end)
obj.modal:bind({"alt"}, "r", rightSizeBookmarksOrHistoryColumn)
obj.modal:bind({"cmd", "shift"}, "n", newBookmarksFolder)
obj.modal:bind({"alt"}, "f", getText)
obj.modal:bind(
  {"cmd"},
  "[",
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
  {"alt"},
  "1",
  function()
    Util.moveFocusToSafariMainArea(obj.thisApp, true)
  end
)

obj.modal:bind(
  {"alt"},
  "2",
  function()
    Util.moveFocusToSafariMainArea(obj.thisApp, false)
  end
)

obj.modal:bind(
  {"cmd", "alt"},
  "left",
  function()
    switchTab("Show Previous Tab")
  end
)

obj.modal:bind(
  {"cmd", "alt"},
  "right",
  function()
    switchTab("Show Next Tab")
  end
)

obj.modal:bind({"cmd"}, "down", firstSearchResult, nil, nil)

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

obj.appScripts = {
  {
    title = "Close Tabs to the Left",
    func = function()
      closeTabs("left")
    end
  },
  {
    title = "Close Tabs to the Right",
    func = function()
      closeTabs("right")
    end
  },
  {
    title = "Duplicate Tab",
    func = duplicateTab
  },
  {
    title = "New Invoice for Current iCount Customer",
    func = newInvoiceForCurrentIcountCustomer
  },
  {
    title = "Open This Tab in Chrome",
    func = openTabInChrome
  },
  {
    title = "Save Page as PDF",
    func = savePageAsPDF
  },
  {
    title = "Translate",
    func = translate
  },
  {
    title = "Open as Private Tab",
    func = openAsPrivateTab
  }
}

obj.listeners = {}

return obj
