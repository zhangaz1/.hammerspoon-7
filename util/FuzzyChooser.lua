-- TESTS
local Chooser = require("hs.chooser")
local Console = require("hs.console")

local obj = {}

obj.chooser = nil
obj.choices = {}
obj.searchBy = nil

local function tableCount(t)
	local n = 0
	for _, _ in pairs(t) do
		n = n + 1
	end
	return n
end

function obj.fuzzyQuery(s, m)
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
				local s_match_length = match_end - match_start
				local score = m:len() / s_match_length
				return score
			end
		else
			s_index = s_index + 1
		end
	end
end

function obj.fuzzyMatcher(query)
	if not obj.chooser then
		-- errors if it's the first run and the chooser is not
		-- yet initialized?
		return
	end
	if query:len() == 0 then
		return obj.chooser:choices(obj.choices)
	end
	local pickedChoices = {}

	for _, choice in pairs(obj.choices) do
		local searchTerm = ""
		for _, choiceField in ipairs(obj.searchBy) do
			searchTerm = searchTerm .. choice[choiceField]:lower()
		end
		local score = obj.fuzzyQuery(searchTerm, query:lower())
		if score > 0 then
			choice["fzf_score"] = score
			table.insert(pickedChoices, choice)
		end
	end
	local sort_func = function(a, b)
		return a["fzf_score"] > b["fzf_score"]
	end
	table.sort(pickedChoices, sort_func)
	return obj.chooser:choices(pickedChoices):rows(tableCount(pickedChoices))
end


function obj.start(callback, choices, searchBy)
	-- local consoleWindow = Console.hswindow()
	-- if consoleWindow then
	--     consoleWindow:close()
	-- end
	obj.searchBy = searchBy
	obj.choices = choices
	obj.chooser = Chooser.new(callback)

	obj.chooser:choices(obj.choices)
	obj.chooser:searchSubText(false)
	obj.chooser:width(33)
	obj.chooser:queryChangedCallback(obj.fuzzyMatcher)
	obj.chooser:rows(tableCount(choices))
	obj.chooser:show()
end

return obj
