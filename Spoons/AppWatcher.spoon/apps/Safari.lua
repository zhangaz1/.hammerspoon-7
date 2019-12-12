local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local ax = require("hs._asm.axuielement")
local observer = require("hs._asm.axuielement").observer
local strictShortcut = require("util.strictShortcut")
local ui = require("util.ui")
local keycodes = require("hs.keycodes")
local timer = require("hs.timer")
local pressAndHold = require("util.PressAndHold")
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

local obj = {}

obj.id = "com.apple.Safari"
obj.thisApp = nil
obj.modal = hotkey.modal.new()
obj.safariPid = nil

local safariAXObject = nil

obj.addressBarWatcher =
  eventtap.new(
  {eventtap.event.types.keyUp},
  function(event)
    -- https://github.com/Hammerspoon/hammerspoon/issues/2167
    local keyCode = event:getKeyCode()
    if (keyCode == keyMap.l or keyCode == keyMap.t) and event:getFlags():containExactly({"cmd"}) then
      obj.safariAXObject = ax.applicationElement(obj.thisApp)
      obj.safariPid = obj.thisApp:pid()
      -- BEGIN HEBREW RELATED
      keycodes.setLayout("ABC")
      -- END HEBREW RELATED
      obj.addressBarReturnKeyWatcher:start()
      obj.addressBarAXObserver("start")
    end
  end
)

obj.addressBarReturnKeyWatcher =
  eventtap.new(
  {eventtap.event.types.keyDown},
  function(event)
    if keycodes.map[event:getKeyCode()] == "return" and event:getFlags():containExactly({}) then
      timer.doAfter(
        0.5,
        function()
          local currentUrl = obj.returnFrontTabURL()
          local match = string.find(currentUrl, "https://.+google")
          if match then
            obj.pane1(true)
          end
          -- BEGIN HEBREW RELATED
          keycodes.setLayout("ABC")
          -- END HEBREW RELATED
          print("stopping address bar watcher...")
          obj.addressBarReturnKeyWatcher:stop()
          obj.addressBarAXObserver("stop")
        end
      )
    end
  end
)

function obj.addressBarAXObserverCallback(_, _, notificationString, _)
  if notificationString == "AXFocusedUIElementChanged" and obj.isAddressBarFocused(obj.safariAXObject) then
    return
  end
  obj.addressBarReturnKeyWatcher:stop()
  obj.addressBarAXObserver("stop")
  print("stopping address bar watcher...")
end

function obj.addressBarAXObserver(mode)
  if mode == "start" then
    safariAXObject =
      observer.new(obj.safariPid):addWatcher(obj.safariAXObject, "AXFocusedUIElementChanged"):addWatcher(
      obj.safariAXObject,
      "AXApplicationDeactivated"
    ):callback(obj.addressBarAXObserverCallback):start()
  elseif mode == "stop" then
    safariAXObject:removeWatcher(obj.safariAXObject, "AXFocusedUIElementChanged"):removeWatcher(
      obj.safariAXObject,
      "AXApplicationDeactivated"
    ):stop()
  end
end

function obj.isAddressBarFocused(axAppObj)
  local addressBarObject =
    ui.getUIElement(
    axAppObj,
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

function obj.pane1(includeSidebar)
  -- pane1 = is either the main web area, or the sidebar
  local targetPane
  local sideBar
  local webArea = ui.getUIElement(obj.thisApp, UIElementPane1StandardView)
  local bookmarksOrHistory = ui.getUIElement(obj.thisApp, UIElementPane1BookmarksHistoryView)
  if includeSidebar then
    sideBar = ui.getUIElement(obj.thisApp, UIElementSidebar)
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

function obj.closeTabs(arg)
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

function obj.translate()
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

function obj.openTabInChrome()
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

function obj.savePageAsPDF()
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

function obj.newBookmarksFolder()
  local title
  title = obj.thisApp:focusedWindow():title()
  if string.match(title, "Bookmarks") then
    ui.getUIElement(obj.thisApp, UIElementNewBookmarksFolderButton):performAction("AXPress")
  else
    obj.modal:exit()
    eventtap.keyStroke({"shift", "cmd"}, "n")
    obj.modal:enter()
  end
end

function obj.newInvoiceForCurrentIcountCustomer()
  local _, url, _ = osascript.applescript('tell application "Safari" to tell window 1 to return URL of current tab')
  url = string.match(url, "id=(%d+)")
  osascript.applescript(
    string.format(
      [[tell application "Safari" to tell window 1 to set URL of current tab to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=%s"]],
      url
    )
  )
end

function obj.rightSizeBookmarksOrHistoryColumn()
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

function obj.duplicateTab()
  eventtap.keyStroke({"cmd"}, "l")
  eventtap.keyStroke({"cmd"}, "return")
  eventtap.keyStroke({"ctrl"}, "tab")
end

function obj.openAsPrivateTab()
  osascript.applescript(
    [[
    tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
    tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
    tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
  ]]
  )
end

function obj.firstSearchResult()
  -- moves focus to the bookmarks/history list
  local title = obj.thisApp:focusedWindow():title()
  -- if we're in the history or bookmarks windows
  if string.match(title, "Bookmarks") or string.match(title, "History") then
    local axApp = ax.applicationElement(obj.thisApp)
    -- if search field is focused
    if axApp:focusedUIElement():attributeValue("AXSubrole") == "AXSearchField" then
      return obj.pane1(false)
    end
  end
  -- otherwise...
  obj.modal:exit()
  eventtap.keyStroke({"cmd"}, "down")
  obj.modal:enter()
end

function obj.switchTab(direction)
  obj.thisApp:selectMenuItem({"Window", direction})
end

function obj.returnFrontTabURL()
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

function obj.showNavMenus(backOrForward)
  local button
  if backOrForward == "forward" then
    button = 2
  else
    button = 1
  end
  ui.getUIElement(
    obj.thisApp:mainWindow(),
    {
      {"AXToolbar", 1},
      {"AXGroup", 1},
      {"AXButton", button}
    }
  ):performAction("AXShowMenu")
end

function obj.showBackMenu()
  obj.showNavMenus("back")
end

function obj.showForwardMenu()
  obj.showNavMenus("forward")
end

obj.modal:bind(
  {"cmd"},
  "[",
  function()
    pressAndHold.onKeyDown(0.2, obj.showBackMenu)
  end,
  function()
    pressAndHold.onKeyUp(obj.modal, {{"cmd"}, keyboard["["]})
  end
)

obj.modal:bind(
  {"cmd"},
  keyboard["]"],
  function()
    pressAndHold.onKeyDown(0.2, obj.showForwardMenu)
  end,
  function()
    pressAndHold.onKeyUp(obj.modal, {{"cmd"}, keyboard["]"]})
  end
)

obj.modal:bind(
  {"alt"},
  "1",
  function()
    obj.pane1(true)
  end
)

obj.modal:bind(
  {"alt"},
  "2",
  function()
    obj.pane1(false)
  end
)

obj.modal:bind(
  {"alt"},
  "r",
  function()
    obj.rightSizeBookmarksOrHistoryColumn()
  end
)

obj.modal:bind(
  {"cmd", "alt"},
  "left",
  function()
    obj.switchTab("Show Previous Tab")
  end
)

obj.modal:bind(
  {"cmd", "alt"},
  "right",
  function()
    obj.switchTab("Show Next Tab")
  end
)

obj.modal:bind(
  {"cmd"},
  "down",
  function()
    obj.firstSearchResult()
  end,
  nil,
  nil
)

obj.modal:bind(
  {"cmd"},
  "n",
  nil,
  function()
    strictShortcut.perform(
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
  {"cmd", "shift"},
  "n",
  function()
    obj.newBookmarksFolder()
  end
)

obj.appScripts = {
  {
    title = "Close Tabs to the Left",
    func = function()
      obj.closeTabs("left")
    end
  },
  {
    title = "Close Tabs to the Right",
    func = function()
      obj.closeTabs("right")
    end
  },
  {
    title = "Duplicate Tab",
    func = function()
      obj.duplicateTab()
    end
  },
  {
    title = "New Invoice for Current iCount Customer",
    func = function()
      obj.newInvoiceForCurrentIcountCustomer()
    end
  },
  {
    title = "Open This Tab in Chrome",
    func = function()
      obj.openTabInChrome()
    end
  },
  {
    title = "Save Page as PDF",
    func = function()
      obj.savePageAsPDF()
    end
  },
  {
    title = "Translate",
    func = function()
      obj.translate()
    end
  },
  {
    title = "Open as Private Tab",
    func = function()
      obj.openAsPrivateTab()
    end
  }
}

obj.listeners = {
  obj.addressBarWatcher
}

return obj
