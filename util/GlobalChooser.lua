local Chooser = require("hs.chooser")
local Console = require("hs.console")

local obj = {}

obj.choices = {}
obj.searchBy = nil
obj.chooser = nil
obj.sentCallback = nil

local function tableCount(t)
    local n = 0
    for _, _ in pairs(t) do n = n + 1 end
    return n
end

local function fuzzyQuery(s, m)
    local s_index = 1
    local m_index = 1
    local match_start = nil
    while true do
        if s_index > s:len() or m_index > m:len() then return -1 end
        local s_char = s:sub(s_index, s_index)
        local m_char = m:sub(m_index, m_index)
        if s_char == m_char then
            if match_start == nil then match_start = s_index end
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

local function fuzzyMatcher(query)
    if not obj.chooser then
        -- errors if it's the first run and the chooser is not
        -- yet initialized?
        return
    end
    if query:len() == 0 then return obj.chooser:choices(obj.choices) end
    local pickedChoices = {}

    for _, choice in pairs(obj.choices) do
        local searchTerm = ""
        for _, choiceField in ipairs(obj.searchBy) do
            local field = choice[choiceField]
            if not field then field = "" end
            searchTerm = searchTerm .. field:lower()
        end
        local score = fuzzyQuery(searchTerm, query:lower())
        if score > 0 then
            choice["fzf_score"] = score
            table.insert(pickedChoices, choice)
        end
    end
    local sort_func = function(a, b) return a["fzf_score"] > b["fzf_score"] end
    table.sort(pickedChoices, sort_func)
    return obj.chooser:choices(pickedChoices):rows((tableCount(pickedChoices)))
end

obj.defaultCallback = function(choice)
    if not choice then return end
    obj.sentCallback(choice)
end

function obj:init()
    self.chooser = Chooser.new(self.defaultCallback):searchSubText(false):width(
                       33):queryChangedCallback(fuzzyMatcher)
end

function obj:start(sentCallback, choices, searchBy)
    -- local consoleWindow = Console.hswindow()
    -- if consoleWindow then
    --     consoleWindow:close()
    -- end
    -- ):rows(tableCount(choices))
    self.choices = choices
    self.sentCallback = sentCallback
    self.searchBy = searchBy
    self.chooser:choices(choices):rows(tableCount(choices)):show()
end

return obj
