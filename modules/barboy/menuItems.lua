local ax = require("hs._asm.axuielement")
local application = require("hs.application")
local hotkey = require('hs.hotkey')
local chooser = require('hs.chooser')
local fnutils = require('hs.fnutils')

local scriptsModule = require("modules.barboy.appScripts")

local mod = {}

-- calculate this once
local frontApp;

-- FUZZY FILTER HELPER
function mod.fuzzyQuery(s, m)
	local s_index = 1
	local m_index = 1
	local match_start = nil
	while true do
		if s_index > s:len() or m_index > m:len() then
			return -1
		end
		local s_char = s:sub(s_index, s_index)
		local m_char = m:sub(m_index, m_index)
		if s_char == m_char then
			if match_start == nil then
				match_start = s_index
			end
			s_index = s_index + 1
			m_index = m_index + 1
			if m_index > m:len() then
				local match_end = s_index
				local s_match_length = match_end-match_start
				local score = m:len()/s_match_length
				return score
			end
		else
			s_index = s_index + 1
		end
	end
end

function mod.fuzzyMatcher(query)
	if query:len() == 0 then
		return mod.barboyChooser:choices(mod.choices)
	end
	local pickedChoices = {}
	for _, j in pairs(mod.choices) do

		local fullText = fnutils.copy(j['path'])
		fullText = table.concat(fullText, ' '):lower()

		local score = mod.fuzzyQuery(fullText, query:lower())
		if score > 0 then
			j["fzf_score"] = score
			table.insert(pickedChoices, j)
		end
	end
	local sort_func = function( a,b ) return a["fzf_score"] > b["fzf_score"] end
	table.sort( pickedChoices, sort_func )
	mod.barboyChooser:choices(pickedChoices)
end

function mod.barboyExecute(choice)
	if not choice then
		return
	elseif choice.type == 'appScript' then
		scriptsModule.executeScript(frontApp, choice.index)
	elseif choice.type == 'menuItem' then
		return frontApp:selectMenuItem(choice.path)
	end
end

function mod.getReadbleName(axElement)
    local titleAttr = axElement:attributeValue('AXTitle')
    local roleDescriptionAttr = axElement:attributeValue('AXRoleDescription')
    local descriptionAttr = axElement:attributeValue('AXDescription')
    local helpAttr = axElement:attributeValue('AXHelp')
    if titleAttr and titleAttr ~= "" then
        return titleAttr
    elseif descriptionAttr and descriptionAttr ~= "" then
        return descriptionAttr
    elseif helpAttr and helpAttr ~= "" then
        return helpAttr
    elseif roleDescriptionAttr and roleDescriptionAttr ~= "" then
        return roleDescriptionAttr
    end
end

function mod.buildMenuItem(axObject, title, path)
	local item = {}
	local AXMenuItemMarkChar = axObject:attributeValue('AXMenuItemMarkChar')
	local AXEnabled = axObject:attributeValue('AXEnabled')
	local isMenu = axObject:attributeValueCount('AXChildren') > 0
	local AXRole = axObject:attributeValue('AXRole')
	local subText = fnutils.copy(path)
	if AXMenuItemMarkChar == '✓' then
		title = '✓ ' .. title
		subText[#subText] = '✓ ' .. subText[#subText]
	end
	if isMenu then
		title = title .. ' >'
		subText[#subText] = subText[#subText] .. ' >'
	end
	if AXRole ~= "AXMenuBarItem" then
		item.subText = table.concat(subText, ' > ')
	end
	-- local AXMenuItemCmdChar = axObject:attributeValue('AXMenuItemCmdChar') -- non modifier key, regular
	-- local AXMenuItemCmdModifiers = axObject:attributeValue('AXMenuItemCmdModifiers') -- modifiers
	-- local AXMenuItemCmdGlyph = axObject:attributeValue('AXMenuItemCmdGlyph') -- virtual keys like ←
	-- local AXMenuItemCmdVirtualKey = axObject:attributeValue('AXMenuItemCmdVirtualKey') -- virtual keys, f1, f2 etc
	-- if AXMenuItemCmdModifiers and AXMenuItemCmdChar then
	--     inspect({commandEnum[AXMenuItemCmdModifiers] .. AXMenuItemCmdChar, AXMenuItemCmdGlyph, AXMenuItemCmdVirtualKey})
	-- end
	item.text = title
	item.type = "menuItem"
	item.path = path
	item.enabled = AXEnabled
	return item
end

local output = {};

function mod.fetchMenuItems(axObject, n, pathArgument)
	-- BARBOY CORE
	-- local menuBarItemBlacklist = {'Apple', 'He lp'}
	-- local traversalDepth;
	-- local maxChildrenForDeeperMenus;
	-- local includeServicesMenuItem;
	-- local skipCommonActions;
    if n then
        n = n + 1
    else
        n = 1
	end

	local path;

	if not axObject then
		local root = ax.applicationElement(frontApp):attributeValue("AXChildren")
		for _ ,v in ipairs(root) do
			if v:attributeValue('AXRole') == 'AXMenuBar' then
				axObject = v:attributeValue('AXChildren')
			end
		end
	end

    for _, uiElement in ipairs(axObject) do
        local title = uiElement:attributeValue('AXTitle')
        if title and title ~= '' and title ~= "Apple" and title ~= "Help" then

			if not pathArgument then -- it's a menu bar item
                path = {title}
            else
                path = fnutils.copy(pathArgument)
                table.insert( path, title )
			end

			local item = mod.buildMenuItem(uiElement, title, path)
			table.insert( output, item )

            if n < 3 then
				local children = uiElement:attributeValueCount('AXChildren')
                if children == 1 then
                    local AXMenu = uiElement[1]
                    if uiElement:attributeValue('AXRole') == 'AXMenuBarItem'
					or (uiElement:attributeValue('AXRole') == 'AXMenuItem' and AXMenu:attributeValueCount('AXChildren') < 20) then
                        mod.fetchMenuItems(AXMenu, n, path)
                    end
                end
			end
        end
	end
	return output
end

mod.barboyChooser = chooser.new(mod.barboyExecute)
	:choices(mod.choices)
	:searchSubText(true)
	:width(33)
	:queryChangedCallback(mod.fuzzyMatcher)

-- BARBOY INIT/CHOOSER
hotkey.bind({"alt"}, "q", function()
	mod.choices = {}
	-- get the active app
	frontApp = application:frontmostApplication()
	fnutils.concat( mod.choices, scriptsModule.loadAppScripts(frontApp) )
	fnutils.concat( mod.choices, mod.fetchMenuItems() )
	mod.barboyChooser:show()
end)

-- local commandEnum = {
--     [0] = '⌘',
--     [1] = '⇧⌘',
--     [2] = '⌥⌘',
--     [3] = '⌥⇧⌘',
--     [4] = '⌃⌘',
--     [5] = '⇧⌃⌘',
--     [6] = '⌃⌥⌘',
--     [7] = '',
--     [8] = '⌦',
--     [9] = '',
--     [10] = '⌥',
--     [11] = '⌥⇧',
--     [12] = '⌃',
--     [13] = '⌃⇧',
--     [14] = '⌃⌥',
-- }

-- local ax = require("hs._asm.axuielement")
-- local application = require("hs.application")
-- local hotkey = require('hs.hotkey')
-- local chooser = require('hs.chooser')
-- local fnutils = require('hs.fnutils')

-- local frontApp;
-- local output = {};

-- local function fuzzyQuery(s, m)
-- 	local s_index = 1
-- 	local m_index = 1
-- 	local match_start = nil
-- 	while true do
-- 		if s_index > s:len() or m_index > m:len() then
-- 			return -1
-- 		end
-- 		local s_char = s:sub(s_index, s_index)
-- 		local m_char = m:sub(m_index, m_index)
-- 		if s_char == m_char then
-- 			if match_start == nil then
-- 				match_start = s_index
-- 			end
-- 			s_index = s_index + 1
-- 			m_index = m_index + 1
-- 			if m_index > m:len() then
-- 				local match_end = s_index
-- 				local s_match_length = match_end-match_start
-- 				local score = m:len()/s_match_length
-- 				return score
-- 			end
-- 		else
-- 			s_index = s_index + 1
-- 		end
-- 	end
-- end

-- local function fetchMenuItems(query, axObject, n, pathArgument)

-- 	if not query or string.len(query) == 0 then
-- 		return
-- 	end

--     if n then
--         n = n + 1
--     else
--         n = 1
-- 	end

-- 	local path;

-- 	if not axObject then
-- 		local root = ax.applicationElement(frontApp):attributeValue("AXChildren")
-- 		for _ ,v in ipairs(root) do
-- 			if v:attributeValue('AXRole') == 'AXMenuBar' then
-- 				axObject = v:attributeValue('AXChildren')
-- 			end
-- 		end
-- 	end

--     for _, uiElement in ipairs(axObject) do
--         local title = uiElement:attributeValue('AXTitle')

-- 		if title and title ~= '' then

-- 			if not pathArgument then -- it's a menu bar item
--                 path = {title}
--             else
--                 path = fnutils.copy(pathArgument)
--                 table.insert( path, title )
-- 			end

-- 			-- local item = mod.buildMenuItem(uiElement, title, path)
-- 			-- table.insert( output, item )
-- 			-- (title)
-- 			local score = fuzzyQuery(title, query)
-- 			if score > 0 then
-- 				print(title)
-- 			end

--             if n < 3 then
-- 				local children = uiElement:attributeValueCount('AXChildren')
--                 if children == 1 then
--                     local AXMenu = uiElement[1]
--                     if uiElement:attributeValue('AXRole') == 'AXMenuBarItem'
-- 					or (uiElement:attributeValue('AXRole') == 'AXMenuItem' and AXMenu:attributeValueCount('AXChildren') < 20) then
--                         fetchMenuItems(query, AXMenu, n, path)
--                     end
--                 end
-- 			end
--         end
-- 	end
-- 	return output
-- end

-- local delayedTimer

-- local function queryChangedFn(query)
-- 	if not delayedTimer then
-- 		delayedTimer = hs.timer.delayed.new(0.3, function()
-- 			fetchMenuItems(query)
-- 		end)
-- 	else
-- 		delayedTimer:start()
-- 	end
-- end

-- local function barboyExecute(choice)
-- 	if choice then return choice end
-- end

-- local barboyChooser = chooser.new(barboyExecute)
-- 	:choices({})
-- 	:searchSubText(true)
-- 	:width(33)
-- 	:queryChangedCallback(queryChangedFn)

-- hotkey.bind({"alt"}, "r", function()
-- 	frontApp = application:frontmostApplication()
-- 	barboyChooser:show()
-- end)
