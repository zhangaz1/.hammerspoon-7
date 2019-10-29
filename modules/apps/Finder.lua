local ax = require("hs._asm.axuielement")
local chooser = require('hs.chooser')
local eventtap = require('hs.eventtap')
local fnutils = require('hs.fnutils')
local geometry = require("hs.geometry")
local hotkey = require("hs.hotkey")
local keycodes = require("hs.keycodes")
local osascript = require("hs.osascript")
local task = require("hs.task")
local timer = require("hs.timer")
local ui = require("util.ui")
local util = require("util.utility")
local window = require("hs.window")

-- http://phrogz.net/lua/LearningLua_Scope.html
-- https://github.com/Hammerspoon/Spoons/blob/master/Source/HoldToQuit.spoon/init.lua
local delayedTimer = nil
local pressAndHold = {
	onKeyDown = function(delay, callBackFn)
			delayedTimer = timer.delayed.new(delay, callBackFn)
			delayedTimer:start()
	end,
	onKeyUp = function(modal, keys)
		if delayedTimer:running() then
			delayedTimer:stop()
			modal:exit()
			eventtap.keyStroke(table.unpack(keys))
			modal:enter()
		end
	end
}

local m = {}

m.id = 'com.apple.finder'
m.thisApp = nil
m.modal = hotkey.modal.new()

function m.getMainArea()
	local mainArea = ui.getUIElement(m.thisApp, {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}})
	if mainArea then
		return mainArea:attributeValue("AXChildren")[1][1]
	end
end

function m.isFilesAreaFocused()
	local axRole
  local axBrowser
	local focused = false

	-- checking for open toolbar menus
	local focusedWindow = m.thisApp:focusedWindow()
	if not focusedWindow then return false end
	local winElement = ax.windowElement(focusedWindow)
	local toolbar = ui.getUIElement(winElement, {
		{'AXToolbar', 1},
	})
	if toolbar then
		for _,v in ipairs(toolbar:attributeValue("AXChildren")) do
			local firstElement = v:attributeValue("AXChildren")
			if firstElement then
				-- axmenu!
				if v[2] then return false end
			end
		end
	end

  local focusedElement = ax.applicationElement(m.thisApp):attributeValue("AXFocusedUIElement")
  local focusedElementDescription = focusedElement:attributeValue("AXDescription")
  if focusedElementDescription == "icon view" or focusedElementDescription == "gallery view" then
      -- check for an active context menu
      local contextMenu = focusedElement:attributeValue("AXChildren")[2]
      if not (contextMenu and contextMenu:attributeValue("AXRole") == "AXMenu") then
        focused = true
      end
    elseif focusedElementDescription == "list view" then
      focused = true
    else
       axRole = focusedElement:attributeValue("AXRole")
      if axRole == "AXList" then
        axBrowser = focusedElement:attributeValue("AXParent"):attributeValue("AXParent"):attributeValue("AXParent")
        if axBrowser:attributeValue("AXDescription") == "column view" then
          focused = true
        end
      end
	end
	return focused
end

function m.getSelection()
	local _, selection, _ = osascript.applescript([[
		tell application "Finder" to set _sel to selection as alias list
		set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {linefeed}}
		return _sel as text
		set AppleScript's text item delimiters to saveTID
	]])
	if not selection then return end
	selection = fnutils.split(selection, '\n')
	-- remove?
	local next = next
		if next(selection) == nil then
			return
		else
			return selection
	end
end

function m.selectionCount()
	local selection = m.getSelection()
	if not selection then return 0 end
	local n = 0
	for i, _ in ipairs(selection) do
		n = i
	end
	return n
end

---

function m.deselectAll()
	for _, k in ipairs({{'Edit', 'Select All'}, {'Edit', 'Deselect All'}}) do
		m.thisApp:selectMenuItem(k)
	end
end

function m.dropboxSmartSyncToggle(syncState)
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
	osascript.applescript(string.format( script, syncState ))
end

function m.rightSizeColumn(arg)
	-- right-size the first column in list view, or the 'active' column in columns view
	-- for columns view: if arg is "all", right sizes all columns indivdually; if arg is "this",
	-- right sizes the 'focused' column individually
	-- for list view, arg is ignored and the first column (usually 'name') is resized
	-- if current view is list view, or if current view is columns view (and arg is "this"): double click divider
	-- if currnet view is columns view and arg is "all": double click divider with option down
	-- get current view from Finder
	local _, currentView, _ = osascript.applescript('tell application "Finder" to return current view of window 1')
	local axApp = ax.applicationElement(m.thisApp)
	local x;
	local y;
	local coords;
	-- columns view
	if currentView == 'clvw' then
		-- focusedElement is a selected Finder item, its parent will be the "active" scroll area
		-- we'll get the position of the column-resize icon based on the selected scroll area's AXFrame
		-- each scroll area represents a Finder column (scroll area 1 = column 1...)
		coords = axApp:focusedUIElement():attributeValue("AXParent"):attributeValue("AXFrame")
		x = (coords.x + coords.w) - 10
		y = (coords.y + coords.h) - 10
		-- list view
	elseif currentView == 'lsvw' then
		-- arg is ignored for list view
		arg = 'this'
		local firstColumn = ui.getUIElement(m.thisApp, {
			{'AXWindow', 1},
			{'AXSplitGroup', 1},
			{'AXSplitGroup', 1},
			{'AXScrollArea', 1},
			{'AXOutline', 1},
			{'AXGroup', 1},
			{'AXButton', 1}
		})
		coords = firstColumn:attributeValue("AXFrame")
		x = coords.x + coords.w
		y = coords.y + (coords.h / 2)
	end
	local point = geometry.point({x,y})
	if arg == 'this' then
		util.doubleLeftClick(point)
	elseif arg == 'all' then
		util.doubleLeftClick(point, {alt = true})
	end
end

function m.browseInLaunchBar()
	osascript.applescript([[
	ignoring application responses
		tell application "LaunchBar" to perform action "Browse Current Folder"
	end ignoring]])
end

function m.duplicateTab()
	-- behaves weirdly with a 0.2 (or shorter) delay
	timer.doAfter(0.3, function()
		osascript.applescript([[
			tell application "Finder" to set _t to target of Finder window 1
			tell application "System Events"
				tell application process "Finder"
					click menu item "New Tab" of menu 1 of menu bar item "File" of menu bar 1
				end tell
			end tell
			tell application "Finder" to set target of Finder window 1 to _t
		]])
	end)
end

function m.selectColumn(choice)
	osascript.applescript([[
		tell application "System Events"
		tell process "Finder"
			click menu item "Show View Options" of menu 1 of menu bar item "View" of menu bar 1
			with timeout of 2 seconds
				repeat until window 1 exists
				end repeat
			end timeout
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

function m.toggleColumns()
	local columnChoices = {}
	local columns = {
		'iCloud Status',
	    'Date Modified',
	    'Date Created',
	    'Date Last Opened',
	    'Date Added',
	    'Size',
	    'Kind',
	    'Version',
	    'Comments',
	    'Tags'
	}
	for _, v in ipairs(columns) do
		local item = { ["text"] = v }
		table.insert( columnChoices, item )
	end
	timer.doAfter(0.1, function()
		chooser.new(m.selectColumn):choices(columnChoices):width(20):show()
	end)
end

function m.focusMainArea()
	-- move focus to files area
	-- scroll area 1 = the common ancestor to all Finder views (list, columns, icons, etc...)
	-- assumption: the files area ui element is different for every view, but it is always to the first child
	m.getMainArea():setAttributeValue("AXFocused", true)
	for _ = 1,3 do
		if m.getSelection() == nil then
			eventtap.keyStroke({}, 'down')
		else
			break
		end
	end
end

function m.focusMainAreaAfterSearch()
	local title = m.thisApp:focusedWindow():title()
	if string.match(title, '^Searching “.+”$') then
		-- if search field is focused
		local axApp = ax.applicationElement(m.thisApp)
		if axApp:focusedUIElement():attributeValue('AXSubrole') == 'AXSearchField' then
			return m.focusMainArea()
		end
	end
	m.modal:exit()
	eventtap.keyStroke({'cmd'}, 'down')
	m.modal:enter()
end

function m.nextSearchScope()
	local searchScopesBar = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXRadioGroup', 1}}
	return ui.cycleUIElements(m.thisApp, searchScopesBar, 'AXRadioButton', 'next')
end

function m.toggleSortingDirection()
	-- this approach is buggy:
	-- returns "name column" even when "date added" is the sort column:
	--tell application "Finder"
	--	tell list view options of Finder window visible
	--		--return sort column
	--		set theCol to name of sort column
	--		return theCol
	--	end tell
	--end tell
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

function m.inverseSelection()
	task.new('/usr/local/bin/node', nil, {'util/inverse-selection/index.js'}):start()
end

function m.undoCloseTab()
	osascript.applescript([[
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
	]])
end

function m.bulkRenamer()
	if (window.frontmostWindow():application():bundleID() == m.id) then
		if m.isFilesAreaFocused() then
			if (m.selectionCount() > 1) then
				osascript.applescript(
				[[tell application "System Events" to click (menu item 1 whose name contains "Rename") of menu 1 of menu bar item "File" of menu bar 1 of application process "Finder"]]
				)
				return
			end
		end
	end
	m.modal:exit()
	eventtap.keyStroke({}, "return")
	m.modal:enter()
end

function m.showNavPopup(backOrForward)
	local buttonNumber
	if backOrForward == "back" then
		buttonNumber = 1
	elseif backOrForward == "forward" then
		buttonNumber = 2
	else
		error("unknown arg")
	end
	local script = [[tell application "System Events"
		tell button %s of group 1 of group 1 of toolbar 1 of window 1 of application process "Finder"
			perform action "AXShowMenu"
		end tell
	end tell]]
  osascript.applescript(string.format( script, buttonNumber))
end

function m.showBackMenu()
	m.showNavPopup("back")
end

function m.showForwardMenu()
	m.showNavPopup("forward")
end

function m.traverseUp()
	osascript.applescript('tell application "LaunchBar" to perform action "Traverse Up"')
end

m.modal:bind({'alt', 'cmd'}, 'left', function() m.thisApp:selectMenuItem({'Window', 'Show Previous Tab'}) end)
m.modal:bind({'alt', 'cmd'}, 'right', function() m.thisApp:selectMenuItem({'Window', 'Show Next Tab'}) end)
m.modal:bind({'alt', 'shift'}, 'r', function() m.rightSizeColumn('all') end)
m.modal:bind({'alt'}, '2', function() m.focusMainArea() end)
m.modal:bind({'alt'}, 'f', function() m.browseInLaunchBar() end)
m.modal:bind({'alt'}, 'r', function() m.rightSizeColumn('this') end)
m.modal:bind({'cmd'}, 'down', function() m.focusMainAreaAfterSearch() end)
m.modal:bind({'cmd'}, 'n', nil, function() util.newWindowForFrontApp(m.thisApp, m.modal) end, nil)
m.modal:bind({'cmd', 'ctrl'}, 'a', function() m.deselectAll() end)
m.modal:bind({'shift' , 'cmd'}, 't', function() m.undoCloseTab() end)
m.modal:bind({'shift', 'cmd'}, 'down', function() m.thisApp:selectMenuItem({'File', 'Open in New Tab'}) end)
m.modal:bind({'shift', 'cmd'}, 'up', function() m.thisApp:selectMenuItem({'File', 'Show Original'}) end)
m.modal:bind({}, 'return', function() m.bulkRenamer() end)
m.modal:bind({"cmd"}, keycodes.map[33],
	function()
		pressAndHold.onKeyDown(0.2, m.showBackMenu)
	end,
	function()
		pressAndHold.onKeyUp(m.modal, {{"cmd"}, keycodes.map[33]})
	end
)
m.modal:bind({"cmd"}, keycodes.map[30],
	function()
		pressAndHold.onKeyDown(0.2, m.showForwardMenu)
	end,
	function()
		pressAndHold.onKeyUp(m.modal, {{"cmd"}, keycodes.map[30]})
	end
)
m.modal:bind(
	{"cmd"},
	"up",
	function()
		pressAndHold.onKeyDown(0.2, m.traverseUp)
	end,
	function()
		pressAndHold.onKeyUp(m.modal, {{"cmd"}, "up"})
	end
)

m.appScripts = {
	{ title = "Toggle Columns", func = function() m.toggleColumns() end},
	{ title = "Toggle Sort Direction", func = function() m.toggleSortingDirection() end},
	{ title = "Dropbox Smart Sync: Local", func = function() m.dropboxSmartSyncToggle("Local") end},
	{ title = "Dropbox Smart Sync: Online Only", func = function() m.dropboxSmartSyncToggle("Online Only") end},
	{ title = "Duplicate Tab", func = function() m.duplicateTab() end },
	{ title = "Deselect All", func = function() m.deselectAll() end },
	{ title = 'Next Search Scope', func = function() m.nextSearchScope() end},
	{ title = 'Inverse Selection', func = function() m.inverseSelection() end},
}

return m
