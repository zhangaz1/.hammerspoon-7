local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")
local geometry = require("hs.geometry")
local timer = require('hs.timer')
local chooser = require('hs.chooser')
local fnutils = require('hs.fnutils')
local eventtap = require('hs.eventtap')
local ax = require("hs._asm.axuielement")
local util = require('util.utility')
local ui = require("util.ui")
local task = require("hs.task")

local m = {}

m.id = 'com.apple.finder'
m.thisApp = nil
m.modal = hotkey.modal.new()

local function deselectAll()
	for _, k in ipairs({{'Edit', 'Select All'}, {'Edit', 'Deselect All'}}) do
		m.thisApp:selectMenuItem(k)
	end
end

local function dropboxSmartSyncToggle()
	osascript.applescript([[
		tell application "System Events"
		set btn to my revealMenu()
		tell btn
			tell menu 1
				delay 0.1
				if value of attribute "AXMenuItemMarkChar" of menu item "Online Only" is "✓" then
					click menu item "Local"
				else if value of attribute "AXMenuItemMarkChar" of menu item "Local" is "✓" then
					click menu item "Online Only"
				else
					set question to display dialog ¬
						"Choose Smart Sync mode" buttons {"Online Only", "Local", "Cancel"} ¬
						default button ¬
						"Local" cancel button "Cancel"
					set _answer to button returned of question
					set btn to my revealMenu()
					tell btn
						tell menu 1
							click menu item _answer
						end tell
					end tell
				end if
			end tell
		end tell
	end tell

	on revealMenu()
		tell application "System Events"
			tell process "Finder"
				tell window 1
					tell toolbar 1
						tell (first group where help contains "Dropbox")
							click menu button 1 -- Dropbox
							delay 0.2
							tell menu 1
								click menu item "Smart Sync"
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
	end revealMenu
	]])
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
		local firstColumn = ui.getUIElement(m.thisApp,
			{{'AXWindow', 1},
			{'AXSplitGroup', 1},
			{'AXSplitGroup', 1},
			{'AXScrollArea', 1},
			{'AXOutline', 1},
			{'AXGroup', 1},
			{'AXButton', 1}})
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

local function browseInLaunchBar()
	osascript.applescript([[
	ignoring application responses
		tell application "LaunchBar" to perform action "Browse Current Folder"
	end ignoring]])
end

local function duplicateTab()
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

local function selectColumn(choice)
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

local function toggleColumns()
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
		chooser.new(selectColumn):choices(columnChoices):width(20):show()
	end)
end

local function resizeIcons(mode)
	osascript.applescript(string.format([[
	set mode to "%s"
	tell application "Finder"
		activate
		tell Finder window 1
			if current view is not icon view then return
			if statusbar visible is true then
				set statusBarEnabled to 1
			else
				set statusBarEnabled to 0
			end if
		end tell
	end tell

	tell application "System Events"
		-- change the size
		tell process "Finder"
			if statusBarEnabled = 0 then
				click menu item "Show Status Bar" of menu 1 of menu bar item "View" of menu bar 1
				delay 0.2
			end if
			tell UI element 2 of window 1
				set _val to value of slider 1
				if _val = 0 then
					set _r to 4
				else
					if mode = "enlarge" then
						set _r to (_val * 2)
					else if mode = "shrink" then
						set _r to (_val / 2)
					end if
				end if
				set value of slider 1 to _r
			end tell
		end tell
	end tell]], mode))
end

local function closeOtherTabs()
	osascript.applescript([[
		tell application "Finder" to set _t to target of Finder window 1
		tell application "System Events"
			tell application process "Finder"
				set frontmost to true
				with timeout of 5 seconds
					repeat while ((count of radio button of tab group 1 of window 1) > 1)
						keystroke "w" using command down
					end repeat
				end timeout
			end tell
		end tell
		tell application "Finder" to set target of Finder window 1 to _t
	]])
end

local function getSelection()
	local _, selection, _ = osascript.applescript([[
		tell application "Finder" to set _sel to selection as alias list
		set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {linefeed}}
		return _sel as text
		set AppleScript's text item delimiters to saveTID
	]])
	selection = fnutils.split(selection, '\n')
	local next = next
		if next(selection) == nil then
			return nil
		else
			return selection
	end
end

local function pane2()
	-- move focus to files area
	-- scroll area 1 = the common ancestor to all Finder views (list, columns, icons, etc...)
	-- assumption: the files area ui element is different for every view, but it is always to the first child
	ui.getUIElement(m.thisApp, {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}})
		:attributeValue("AXChildren")[1][1]
		:setAttributeValue("AXFocused", true)
	for _ = 1,3 do
		if getSelection() == nil then
			eventtap.keyStroke({}, 'down')
		else
			break
		end
	end
end

local function moveToFirstSearchResult()
	local title = m.thisApp:focusedWindow():title()
	if string.match(title, '^Searching “.+”$') then
		-- if search field is focused
		local axApp = ax.applicationElement(m.thisApp)
		if axApp:focusedUIElement():attributeValue('AXSubrole') == 'AXSearchField' then
			return pane2()
		end
	end
	m.modal:exit()
	eventtap.keyStroke({'cmd'}, 'down')
	m.modal:enter()
end

local function nextSearchScope()
	local searchScopesBar = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXRadioGroup', 1}}
	return ui.cycleUIElements(m.thisApp, searchScopesBar, 'AXRadioButton', 'next')
end

local function toggleSortingDirection()
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

local function inverseSelection()
	task.new('/usr/local/bin/node', nil, {'util/inverse-selection/index.js'}):start()
end

local function undoCloseTab()
	osascript.applescript([[
	tell application "Default Folder X"
		set recentFinderWindows to GetRecentFinderWindows
		set lastTab to POSIX path of item 1 of recentFinderWindows
	end tell
	do shell script "open " & quoted form of lastTab
	]])
end

m.modal:bind({'alt'}, 'f', function() browseInLaunchBar() end)
m.modal:bind({'alt'}, 'o', function() showPackageContents() end)
m.modal:bind({'alt'}, 'r', function() rightSizeColumn('this') end)
m.modal:bind({'alt', 'shift'}, 'r', function() rightSizeColumn('all') end)
m.modal:bind({'cmd'}, 'n', nil, function() util.newWindowForFrontApp(m.thisApp, m.modal) end, nil)
m.modal:bind({'cmd'}, 'down', function() moveToFirstSearchResult() end)
m.modal:bind({'shift', 'cmd'}, 'down', function() m.thisApp:selectMenuItem({'File', 'Open in New Tab'}) end)
m.modal:bind({'shift', 'cmd'}, 'up', function() m.thisApp:selectMenuItem({'File', 'Show Original'}) end)
m.modal:bind({'alt', 'cmd'}, 'left', function() m.thisApp:selectMenuItem({'Window', 'Show Previous Tab'}) end)
m.modal:bind({'alt', 'cmd'}, 'right', function() m.thisApp:selectMenuItem({'Window', 'Show Next Tab'}) end)
m.modal:bind({'ctrl'}, 'a', function() deselectAll() end)
m.modal:bind({'alt'}, '2', function() pane2() end)
m.modal:bind({'shift' , 'cmd'}, 't', function() undoCloseTab() end)

-- BEGIN HIGH-SIERRA SUPPORT
if util.isHighSierra() then
	m.modal:bind({'cmd', 'alt'}, 'w', function() closeOtherTabs() end)
	m.modal:bind({'cmd'}, '=', function() resizeIcons("enlarge") end)
	m.modal:bind({'cmd'}, '-', function() resizeIcons("shrink") end)
end
-- END HIGH-SIERRA SUPPORT

m.appScripts = {
	-- { title = 'Quick Actions', func = function() quickActions.quickActions() end},
	{ title = "Toggle Columns", func = function() toggleColumns() end},
	{ title = "Toggle Sort Direction", func = function() toggleSortingDirection() end},
	{ title = "Dropbox Smart Sync Toggle", func = function() dropboxSmartSyncToggle() end},
	{ title = "Duplicate Tab", func = function() duplicateTab() end },
	{ title = "Deselect All", func = function() deselectAll() end },
	{ title = 'Next Search Scope', func = function() nextSearchScope() end},
	{ title = 'Inverse Selection', func = function() inverseSelection() end},
	-- { title = "Show More", func = function() showMore() end },
}

return m
