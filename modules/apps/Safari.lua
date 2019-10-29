local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local ax = require("hs._asm.axuielement")
local observer = require("hs._asm.axuielement").observer
local util = require('util.utility')
local ui = require("util.ui")
local keycodes = require("hs.keycodes")
local timer = require("hs.timer")

local m = {}

m.id = 'com.apple.Safari'
m.thisApp = nil
m.modal = hotkey.modal.new()

m.axObserver = nil

m.waitForPressingReturn = eventtap.new(
  {eventtap.event.types.keyUp},
  function(event)
    local keyName = keycodes.map[event:getKeyCode()]
    if keyName == "return" and event:getFlags():containExactly({}) then
        timer.doAfter(0.5, function()
          local currentUrl = m.returnUrlForFrontTab()
          local match = string.find( currentUrl, "google" )
          print(currentUrl, match)
          if match then
            m.pane1(true)
          end
          m.waitForPressingReturn:stop()
          m.axObserver:stop()
          print("STOPPED WAITING FOR RETURN")
        end)
    end
    return
end)

m.newAddressBarActionWatcher = eventtap.new(
{eventtap.event.types.keyUp},
function(event)
  local t = keycodes.map["t"]
  local l = keycodes.map["l"]
  local keyCode = event:getKeyCode()
  if (keyCode == l or keyCode == t) and event:getFlags():containExactly({"cmd"}) then
    -- BEGIN HEBREW RELATED
    keycodes.setLayout("ABC")
    -- END HEBREW RELATED
    if m.waitForPressingReturn:isEnabled() then return end
    m.waitForPressingReturn:start()
    print("WAITING FOR RETURN")
    local safariAxObj = ax.applicationElement(m.thisApp)
    local safariPid = m.thisApp:pid()
    m.axObserver = observer.new(safariPid)
    :addWatcher(safariAxObj, "AXFocusedUIElementChanged")
    :addWatcher(safariAxObj, "AXApplicationDeactivated")
    :callback(
      function(_, _, _, _)
        m.waitForPressingReturn:stop()
        m.axObserver:stop()
        print("STOPPED WAITING FOR RETURN")
      end)
    :start()
  end
  return
end)

-- the statusbar overlay is AXWindow 1!
local uiElement_sideBar = { {'AXWindow', 'AXRoleDescription', 'standard window'}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1} }
local uiElement_pane1Regular = { {'AXWindow', 'AXRoleDescription', 'standard window'}, {'AXSplitGroup', 1}, {'AXTabGroup', 1}, {'AXGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXWebArea', 1} }
local uiElement_pane1BookmarksHistory = { {'AXWindow', 'AXRoleDescription', 'standard window'}, {'AXSplitGroup', 1}, {'AXTabGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1} }
local newBookmarksFolderButton = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXTabGroup', 1}, {'AXGroup', 1}, {'AXButton', 1}}

m.pane1 = function(includeSidebar)
  -- pane1 = is either the main web area, or the sidebar
  local targetPane;
  local sideBar;
  local webArea = ui.getUIElement(m.thisApp, uiElement_pane1Regular)
  local bookmarksOrHistory = ui.getUIElement(m.thisApp, uiElement_pane1BookmarksHistory)
  if includeSidebar then
    sideBar = ui.getUIElement(m.thisApp, uiElement_sideBar)
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
  return targetPane:setAttributeValue('AXFocused', true)
end

m.closeTabs = function(arg)
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

m.translate = function()
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

m.openTabInChrome = function()
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

m.savePageAsPdf = function()
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

m.newBookmarksFolder = function()
  local title;
  title = m.thisApp:focusedWindow():title()
  if string.match(title, 'Bookmarks') then
    ui.getUIElement(m.thisApp, newBookmarksFolderButton):performAction('AXPress')
  else
    m.modal:exit()
    eventtap.keyStroke({'shift', 'cmd'}, 'n')
    m.modal:enter()
  end
end

m.newInvoiceForCurrentIcountCustomer = function()
  local _, url, _ = osascript.applescript('tell application "Safari" to tell window 1 to return URL of current tab')
  url = string.match(url, "id=(%d+)")
  osascript.applescript(string.format([[tell application "Safari" to tell window 1 to set URL of current tab to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=%s"]], url))
end

m.rightSizeBookmarksOrHistoryColumn = function()
  local bool, data, _ = osascript.applescript([[
  tell application "System Events" to tell process "Safari" to tell window 1 to tell splitter group 1 to tell tab group 1 to tell group 1 to tell scroll area 1 to tell outline 1 to tell group 1 to tell button "Website"
    set thePosition to position
    set theSize to size
    return {x:item 1 of thePosition, y:item 2 of thePosition, w:item 1 of theSize, h:item 2 of theSize}
  end tell]])
  if not bool then return end
  local x = data.x + data.w
  local y = data.y + 5
  util.doubleLeftClick({x, y})
end

m.duplicateTab = function()
  eventtap.keyStroke({'cmd'}, 'l')
  eventtap.keyStroke({'cmd'}, 'return')
  eventtap.keyStroke({'ctrl'}, 'tab')
end

m.openAsPrivateTab = function()
  osascript.applescript([[
    tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
    tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
    tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
  ]])
end

m.firstSearchResult = function()
  -- moves focus to the bookmarks/history list
  local title = m.thisApp:focusedWindow():title()
  -- if we're in the history or bookmarks windows
  if string.match(title, 'Bookmarks') or string.match(title, 'History') then
    local axApp = ax.applicationElement(m.thisApp)
    -- if search field is focused
    if axApp:focusedUIElement():attributeValue('AXSubrole') == 'AXSearchField' then
      return m.pane1(false)
    end
  end
  -- otherwise...
  m.modal:exit()
  eventtap.keyStroke({'cmd'}, 'down')
  m.modal:enter()
end

m.switchTab = function(direction)
  m.thisApp:selectMenuItem({'Window', direction})
end

m.returnUrlForFrontTab = function()
  local _, b, _ = osascript.applescript([[
  tell application "Safari"
    tell (window 1 whose visible of it = true)
      tell (tab 1 whose visible of it = true)
        return URL
      end tell
    end tell
  end tell
  ]])
  return b
end

m.modal:bind({'alt'}, '1', function() m.pane1(true) end)
m.modal:bind({'alt'}, '2', function() m.pane1(false) end)
m.modal:bind({'alt'}, 'r', function() m.rightSizeBookmarksOrHistoryColumn() end)
m.modal:bind({'cmd', 'alt'}, 'left', function() m.switchTab('Show Previous Tab') end)
m.modal:bind({'cmd', 'alt'}, 'right', function() m.switchTab('Show Next Tab') end)
m.modal:bind({'cmd'}, 'down', function() m.firstSearchResult() end, nil, nil)
m.modal:bind({'cmd'}, 'n', nil, function() util.newWindowForFrontApp(m.thisApp, m.modal) end, nil)
m.modal:bind({'cmd', 'shift'}, 'n', function() m.newBookmarksFolder() end)

m.appScripts = {
  { title = "Close Tabs to the Left", func = function() m.closeTabs("left") end },
  { title = "Close Tabs to the Right", func = function() m.closeTabs("right") end },
  { title = "Duplicate Tab", func = function() m.duplicateTab() end},
  { title = "New Invoice for Current iCount Customer", func = function() m.newInvoiceForCurrentIcountCustomer() end},
  { title = "Open This Tab in Chrome", func = function() m.openTabInChrome() end},
  { title = "Save Page as PDF", func = function() m.savePageAsPdf() end},
  { title = "Translate", func = function() m.translate() end},
  { title = "Open as Private Tab", func = function() m.openAsPrivateTab() end},
}

m.listeners = {
  m.newAddressBarActionWatcher
}

return m
