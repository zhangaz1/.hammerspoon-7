local ax = require("hs._asm.axuielement")

local mod = {}

local function tableCount(t)
  local n = 0
  for _, _ in pairs(t) do
    n = n + 1
  end
  return n
end

function mod.getUIElement(appOrWindowOrAx, uiPathTable)
	local n;
	local match;
	local numeralIndexReferenceMode;
	local role;
	local indexOrAttribute;
	local attributeValue;
	local childs;

	local targetElement;

	-- if an hsapp
	if appOrWindowOrAx.bundleID then
		targetElement = ax.applicationElement(appOrWindowOrAx)
	elseif appOrWindowOrAx.maximize then
		targetElement = ax.windowElement(appOrWindowOrAx)
	else
		targetElement = appOrWindowOrAx
	end

	-- pathItem is sent by the user
	for _, pathItem in ipairs(uiPathTable) do
		role = pathItem[1]
		indexOrAttribute = pathItem[2]
		-- iterator
		n = 1
		-- all child UI elements
		childs = targetElement:attributeValue("AXChildren")

		-- if 0 childs, return
		-- print(hs.inspect(childs))
		if not childs or tableCount(childs) == 0 then
			return nil
		end

		-- for the current pathItem, checking for an index/attribute-value reference
		if tonumber(indexOrAttribute) then
			numeralIndexReferenceMode = true
		else
			numeralIndexReferenceMode = false
			attributeValue = pathItem[3]
		end
		match = false
		for _, childElement in ipairs(childs) do
			-- checking for matching role
			if childElement:attributeValue("AXRole") == role then
				-- checking if a numeral index
				if numeralIndexReferenceMode then
					if indexOrAttribute == n then
						match = true
					else
						n = n + 1
					end
				elseif childElement:attributeValue(indexOrAttribute) == attributeValue then
					match = true
				end
			end
			if match then
				-- break the current loop as there's no need to continue traversing the current children heirarchy
				-- assign the newly found targetElement back to the targetElement var
				targetElement = childElement
				break
			end
		end
		if not match then
			return nil
		end
	end
	return targetElement
end

function mod.cycleUIElements(hsAppObj, parentUIGroup, elementRole, direction)
	-- cycles left (next) or right (prev) through a group of similar ui elements, under a common parent
	local axParent = mod.getUIElement(hsAppObj, parentUIGroup)
	local elements = axParent:attributeValue('AXChildren')
	local totalElements = 0;
	local selectedElement = 0;
	local targetElement;
	for _, element in ipairs(elements) do
		if element:attributeValue('AXRole') == elementRole then
			totalElements = totalElements + 1
			if element:attributeValue('AXValue') == 1 then
				selectedElement = totalElements
			end
		end
	end
	if direction == 'next' then
		if selectedElement == totalElements then
			targetElement = 1
		else
			targetElement = selectedElement + 1
		end
	elseif direction == 'prev' then
		if selectedElement == 1 then
			targetElement = totalElements
		else
			targetElement = selectedElement - 1
		end
	end
	-- create the new target element as string, add it to the ui path
	targetElement = {elementRole, targetElement}
	table.insert(parentUIGroup, targetElement)
	mod.getUIElement(hsAppObj, parentUIGroup):performAction('AXPress')
end

return mod
