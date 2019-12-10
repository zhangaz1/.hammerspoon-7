local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local ax = require("hs._asm.axuielement")
local observer = require("hs._asm.axuielement").observer
local util = require("util.utility")
local ui = require("util.ui")
local keycodes = require("hs.keycodes")
local timer = require("hs.timer")
local pressAndHold = require("util.pressAndHold")
local DoubleLeftClick = require("util.doubleLeftClick")

local keyMap = {
  -- hs.keycodes.map.l
  -- t = hs.keycodes.map[17],
  -- l = hs.keycodes.map[37]
  t = 17,
  l = 37,
  ["]"] = 30
}

local keyboard = {
  ["]"] = keycodes.map[30],
  ["["] = keycodes.map[33]
}

local m = {}

m.id = "com.apple.Safari"
m.thisApp = nil
m.modal = hotkey.modal.new()

newAddressBarActionWatcher =
  eventtap.new(
  {eventtap.event.types.keyUp},
  function(event)
    -- https://github.com/Hammerspoon/hammerspoon/issues/2167
    local keyCode = event:getKeyCode()
    if (keyCode == keyMap.l or keyCode == keyMap.t) and event:getFlags():containExactly({"cmd"}) then
      -- BEGIN HEBREW RELATED
      keycodes.setLayout("ABC")
      -- END HEBREW RELATED
      m.awaitReturnKeyFn("start")
      m.addressBarObserver("start")
    end
  end
)

-- the statusbar overlay is AXWindow 1!
local UIElementSidebar = {
  {"AXWindow", "AXRoleDescription", "standard window"},
  {"AXSplitGroup", 1},
  {"AXGroup", 1},
  {"AXScrollArea", 1},
  {"AXOutline", 1}
}
local UIElementPane1StandardView = {
  {"AXWindow", "AXRoleDescription", "standard window"},
  {"AXSplitGroup", 1},
  {"AXTabGroup", 1},
  {"AXGroup", 1},
  {"AXGroup", 1},
  {"AXScrollArea", 1},
  {"AXWebArea", 1}
}
local UIElementPane1BookmarksHistoryView = {
  {"AXWindow", "AXRoleDescription", "standard window"},
  {"AXSplitGroup", 1},
  {"AXTabGroup", 1},
  {"AXGroup", 1},
  {"AXScrollArea", 1},
  {"AXOutline", 1}
}
local UIElementNewBookmarksFolderButton = {
  {"AXWindow", 1},
  {"AXSplitGroup", 1},
  {"AXTabGroup", 1},
  {"AXGroup", 1},
  {"AXButton", 1}
}

m.axObserver = nil
m.returnKeyEventTap = nil

function m.isAddressBarFocused(safariAXObject)
  local addressBarObject =
    ui.getUIElement(
    safariAXObject,
    {
      {"AXWindow", "AXMain", true},
      {"AXToolbar", 1}
    }
  ):attributeValue("AXChildren")
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

function m.addressBarObserver(arg)
  if arg == "stop" then
    m.axObserver:stop()
    return
  end
  if arg == "start" then
    if m.axObserver and m.axObserver:isRunning() then
      return
    end
    local safariAXObject = ax.applicationElement(m.thisApp)
    local safariPid = m.thisApp:pid()
    m.axObserver =
      observer.new(safariPid):addWatcher(safariAXObject, "AXFocusedUIElementChanged"):addWatcher(
      safariAXObject,
      "AXApplicationDeactivated"
    ):callback(
      function(_, _, notificationString, _)
        if notificationString == "AXApplicationDeactivated" then
          m.awaitReturnKeyFn("stop")
          m.addressBarObserver("stop")
        elseif notificationString == "AXFocusedUIElementChanged" then
          -- checking if indeed the address lost focus
          if not m.isAddressBarFocused(safariAXObject) then
            m.addressBarObserver("stop")
            m.awaitReturnKeyFn("stop")
          end
        end
      end
    ):start()
  end
end

function m.awaitReturnKeyFn(arg)
  if arg == "stop" then
    m.returnKeyEventTap:stop()
    return
  end
  if arg == "start" then
    if m.returnKeyEventTap and m.returnKeyEventTap:isEnabled() then
      return
    end
    m.returnKeyEventTap =
      eventtap.new(
      {eventtap.event.types.keyDown},
      function(event)
        if keycodes.map[event:getKeyCode()] == "return" and event:getFlags():containExactly({}) then
          timer.doAfter(
            0.5,
            function()
              local currentUrl = m.returnFrontTabURL()
              local match = string.find(currentUrl, "https://.+google")
              if match then
                --
                m.pane1(true)
              --
              end
              -- BEGIN HEBREW RELATED
              keycodes.setLayout("ABC")
              -- END HEBREW RELATED
              m.awaitReturnKeyFn("stop")
              m.addressBarObserver("stop")
            end
          )
        end
      end
    ):start()
  end
end

function m.pane1(includeSidebar)
  -- pane1 = is either the main web area, or the sidebar
  local targetPane
  local sideBar
  local webArea = ui.getUIElement(m.thisApp, UIElementPane1StandardView)
  local bookmarksOrHistory = ui.getUIElement(m.thisApp, UIElementPane1BookmarksHistoryView)
  if includeSidebar then
    sideBar = ui.getUIElement(m.thisApp, UIElementSidebar)
  else
    sideBar = nil
  end

  if sideBar then
    targetPane = sideBar
  elseif webArea then
    targetPane = webArea
  elseif bookmarksOrHistory then
    targetPane = bookmarksOrHistory
  end
  return targetPane:setAttributeValue("AXFocused", true)
end

function m.closeTabs(arg)
  osascript.applescript(
    string.format(
      [[
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
    end tell]],
      arg
    )
  )
end

function m.translate()
  osascript.applescript(
    [[
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
  end tell]]
  )
end

function m.openTabInChrome()
  osascript.applescript(
    [[
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
  end tell]]
  )
end

function m.savePageAsPDF()
  osascript.applescript(
    [[
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
    end tell]]
  )
end

function m.newBookmarksFolder()
  local title
  title = m.thisApp:focusedWindow():title()
  if string.match(title, "Bookmarks") then
    ui.getUIElement(m.thisApp, UIElementNewBookmarksFolderButton):performAction("AXPress")
  else
    m.modal:exit()
    eventtap.keyStroke({"shift", "cmd"}, "n")
    m.modal:enter()
  end
end

function m.newInvoiceForCurrentIcountCustomer()
  local _, url, _ = osascript.applescript('tell application "Safari" to tell window 1 to return URL of current tab')
  url = string.match(url, "id=(%d+)")
  osascript.applescript(
    string.format(
      [[tell application "Safari" to tell window 1 to set URL of current tab to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=%s"]],
      url
    )
  )
end

function m.rightSizeBookmarksOrHistoryColumn()
  local bool, data, _ =
    osascript.applescript(
    [[
  tell application "System Events" to tell process "Safari" to tell window 1 to tell splitter group 1 to tell tab group 1 to tell group 1 to tell scroll area 1 to tell outline 1 to tell group 1 to tell button "Website"
    set thePosition to position
    set theSize to size
    return {x:item 1 of thePosition, y:item 2 of thePosition, w:item 1 of theSize, h:item 2 of theSize}
  end tell]]
  )
  if not bool then
    return
  end
  local x = data.x + data.w
  local y = data.y + 5
  DoubleLeftClick.start({x, y})
end

function m.duplicateTab()
  eventtap.keyStroke({"cmd"}, "l")
  eventtap.keyStroke({"cmd"}, "return")
  eventtap.keyStroke({"ctrl"}, "tab")
end

function m.openAsPrivateTab()
  osascript.applescript(
    [[
    tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
    tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
    tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
  ]]
  )
end

function m.firstSearchResult()
  -- moves focus to the bookmarks/history list
  local title = m.thisApp:focusedWindow():title()
  -- if we're in the history or bookmarks windows
  if string.match(title, "Bookmarks") or string.match(title, "History") then
    local axApp = ax.applicationElement(m.thisApp)
    -- if search field is focused
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return m.pane1(false)
    end
  end
  -- otherwise...
  m.modal:exit()
  eventtap.keyStroke({"cmd"}, "down")
  m.modal:enter()
end

function m.switchTab(direction)
  m.thisApp:selectMenuItem({"Window", direction})
end

function m.returnFrontTabURL()
  local _, b, _ =
    osascript.applescript(
    [[
  tell application "Safari"
    tell (window 1 whose visible of it = true)
      tell (tab 1 whose visible of it = true)
        return URL
      end tell
    end tell
  end tell
  ]]
  )
  return b
end

function m.showNavMenus(backOrForward)
  local button
  if backOrForward == "forward" then
    button = 2
  else
    button = 1
  end
  ui.getUIElement(
    m.thisApp:mainWindow(),
    {
      {"AXToolbar", 1},
      {"AXGroup", 1},
      {"AXButton", button}
    }
  ):performAction("AXShowMenu")
end

function m.showBackMenu()
  m.showNavMenus("back")
end

function m.showForwardMenu()
  m.showNavMenus("forward")
end

m.modal:bind(
  {"cmd"},
  "[",
  function()
    pressAndHold.onKeyDown(0.2, m.showBackMenu)
  end,
  function()
    pressAndHold.onKeyUp(m.modal, {{"cmd"}, keyboard["["]})
  end
)

m.modal:bind(
  {"cmd"},
  keyboard["]"],
  function()
    pressAndHold.onKeyDown(0.2, m.showForwardMenu)
  end,
  function()
    pressAndHold.onKeyUp(m.modal, {{"cmd"}, keyboard["]"]})
  end
)

m.modal:bind(
  {"alt"},
  "1",
  function()
    m.pane1(true)
  end
)

m.modal:bind(
  {"alt"},
  "2",
  function()
    m.pane1(false)
  end
)

m.modal:bind(
  {"alt"},
  "r",
  function()
    m.rightSizeBookmarksOrHistoryColumn()
  end
)

m.modal:bind(
  {"cmd", "alt"},
  "left",
  function()
    m.switchTab("Show Previous Tab")
  end
)

m.modal:bind(
  {"cmd", "alt"},
  "right",
  function()
    m.switchTab("Show Next Tab")
  end
)

m.modal:bind(
  {"cmd"},
  "down",
  function()
    m.firstSearchResult()
  end,
  nil,
  nil
)

m.modal:bind(
  {"cmd"},
  "n",
  nil,
  function()
    util.newWindowForFrontApp(m.thisApp, m.modal)
  end,
  nil
)

m.modal:bind(
  {"cmd", "shift"},
  "n",
  function()
    m.newBookmarksFolder()
  end
)

m.appScripts = {
  {
    title = "Close Tabs to the Left",
    func = function()
      m.closeTabs("left")
    end
  },
  {
    title = "Close Tabs to the Right",
    func = function()
      m.closeTabs("right")
    end
  },
  {
    title = "Duplicate Tab",
    func = function()
      m.duplicateTab()
    end
  },
  {
    title = "New Invoice for Current iCount Customer",
    func = function()
      m.newInvoiceForCurrentIcountCustomer()
    end
  },
  {
    title = "Open This Tab in Chrome",
    func = function()
      m.openTabInChrome()
    end
  },
  {
    title = "Save Page as PDF",
    func = function()
      m.savePageAsPDF()
    end
  },
  {
    title = "Translate",
    func = function()
      m.translate()
    end
  },
  {
    title = "Open as Private Tab",
    func = function()
      m.openAsPrivateTab()
    end
  }
}

m.listeners = {
  newAddressBarActionWatcher
}

return m
