local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local eventtap = require("hs.eventtap")
local ax = require("hs._asm.axuielement")
local util = require('util.utility')
local ui = require("util.ui")

local m = {}

m.id = 'com.apple.Safari'
m.thisApp = nil
m.modal = hotkey.modal.new()


-- the statusbar overlay is AXWindow 1 !
local uiElement_sideBar = { {'AXWindow', 'AXRoleDescription', 'standard window'}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1} }
local uiElement_pane1Regular = { {'AXWindow', 'AXRoleDescription', 'standard window'}, {'AXSplitGroup', 1}, {'AXTabGroup', 1}, {'AXGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXWebArea', 1} }
local uiElement_pane1BookmarksHistory = { {'AXWindow', 'AXRoleDescription', 'standard window'}, {'AXSplitGroup', 1}, {'AXTabGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1} }
local uiElementNewBookmarksFolderBtn = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXTabGroup', 1}, {'AXGroup', 1}, {'AXButton', 1}}

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

local function savePageAsPdf()
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
	ui.getUIElement(m.thisApp, uiElementNewBookmarksFolderBtn):performAction('AXPress')
end

local function newBookmarksFolderByHotkey()
	local title;
	title = m.thisApp:focusedWindow():title()
	if string.match(title, 'Bookmarks') then
		newBookmarksFolder()
	else
		m.modal:exit()
		eventtap.keyStroke({'shift', 'cmd'}, 'n')
		m.modal:enter()
	end
end

local function newInvoiceForCurrentIcountCustomer()
	local _, url, _ = osascript.applescript('tell application "Safari" to tell window 1 to return URL of current tab')
	url = string.match(url, "id=(%d+)")
	osascript.applescript(string.format([[tell application "Safari" to tell window 1 to set URL of current tab to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=%s"]], url))
end

local function rightSizeBookmarksOrHistoryColumn()
	local bool, data, _ = osascript.applescript([[tell application "System Events" to tell process "Safari" to tell window 1 to tell splitter group 1 to tell tab group 1 to tell group 1 to tell scroll area 1 to tell outline 1 to tell group 1 to tell button "Website"
		set thePosition to position
		set theSize to size
		return {x:item 1 of thePosition, y:item 2 of thePosition, w:item 1 of theSize, h:item 2 of theSize}
	end tell]])
	if not bool then return end
	local x = data.x + data.w
	local y = data.y + 5
	util.doubleLeftClick({x, y})
end

local function duplicateTab()
	eventtap.keyStroke({'cmd'}, 'l')
	eventtap.keyStroke({'cmd'}, 'return')
	eventtap.keyStroke({'ctrl'}, 'tab')
end

local function openAsPrivateTab()
	osascript.applescript([[
		tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
		tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
		tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
	]])
end

local function pane1(includeSidebar)
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

local function firstSearchResult()
	-- moves focus to the bookmarks/history list
	local title = m.thisApp:focusedWindow():title()
	-- if we're in the history or bookmarks windows
	if string.match(title, 'Bookmarks') or string.match(title, 'History') then
		local axApp = ax.applicationElement(m.thisApp)
		-- if search field is focused
		if axApp:focusedUIElement():attributeValue('AXSubrole') == 'AXSearchField' then
			return pane1(false)
		end
	end
	-- otherwise...
	m.modal:exit()
	eventtap.keyStroke({'cmd'}, 'down')
	m.modal:enter()
end

local function switchTab(direction)
	m.thisApp:selectMenuItem({'Window', direction})
end

m.modal:bind({'alt'}, '1', function() pane1(true) end)
m.modal:bind({'alt'}, '2', function() pane1(false) end)
m.modal:bind({'alt'}, 'r', function() rightSizeBookmarksOrHistoryColumn() end)
m.modal:bind({'cmd', 'alt'}, 'left', function() switchTab('Show Previous Tab') end)
m.modal:bind({'cmd', 'alt'}, 'right', function() switchTab('Show Next Tab') end)
m.modal:bind({'cmd'}, 'down', function() firstSearchResult() end, nil, nil)
m.modal:bind({'cmd'}, 'n', nil, function() util.newWindowForFrontApp(m.thisApp, m.modal) end, nil)
m.modal:bind({'cmd', 'shift'}, 'n', function() newBookmarksFolderByHotkey() end)

m.appScripts = {
  { title = "Close Tabs to the Left", func = function() closeTabs("left") end },
  { title = "Close Tabs to the Right", func = function() closeTabs("right") end },
  { title = "Duplicate Tab", func = function() duplicateTab() end},
  { title = "New Bookmarks Folder", func = function() newBookmarksFolder() end},
  { title = "New Invoice for Current iCount Customer", func = function() newInvoiceForCurrentIcountCustomer() end},
  { title = "Open This Tab in Chrome", func = function() openTabInChrome() end},
  { title = "Save Page as PDF", func = function() savePageAsPdf() end},
  { title = "Translate", func = function() translate() end},
  { title = "Open as Private Tab", func = function() openAsPrivateTab() end},
}

return m
