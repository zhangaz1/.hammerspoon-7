-- TESTS
local spotlight = require("hs.spotlight")
local chooserPanel = require("hs.chooser")

local chooser;
local searcher;
local HOME = os.getenv("HOME")

local searchPaths = {
     HOME .. "/Dropbox",
     HOME .. "/Library/Application Support",
     HOME .. "/Library/Preferences",
     HOME .. "/Desktop",
     HOME .. "/Downloads",
    "/Applications",
    "/usr/local/bin",
    ""
}

local predefinedScopes = hs.spotlight.definedSearchScopes

local function completionFn(choice)
    searcher:stop()
    if not choice then return end
    hs.timer.doAfter(0.5, function()
        hs.osascript.applescript(string.format([[tell application "Default Folder X" to SwitchToFolder "%s"]], choice.subText))
    end)
end

local function searchCompletionFn(spotlightObject, msg, info)
    local items = {}
    for _ ,v in ipairs(spotlightObject) do
        local item = {
            text = v.kMDItemDisplayName,
            subText = v.kMDItemPath,
        }
        if v.kMDItemPath then item.image = hs.image.iconForFile(v.kMDItemPath) end
        table.insert( items, item )
    end
    chooser:choices(items)
end

local function spotlightSearch(searchQuery)
    hs.timer.delayed.new(1, function()
        searcher:queryString(string.format([[ kMDItemDisplayName LIKE[cd] "%s*" ]], searchQuery ))
    end):start()
end

local key;

local fn = function()
    local _, result, _ = hs.osascript.applescript([[tell application "Default Folder X" to return IsDialogOpen]])
    if result == false then
        key:disable()
        hs.eventtap.keyStroke({"shift", "cmd"}, "g")
        key:enable()
    else
        chooser = chooserPanel.new(completionFn)
            :queryChangedCallback(spotlightSearch)
            :width(25)
        searcher = spotlight.new()
            -- start with an empty query
            :setCallback(searchCompletionFn)
            :queryString([[ kMDItemFSName == "" ]])
            :searchScopes(hs.spotlight.definedSearchScopes)
            :start()
        chooser:show()
    end
end

key = hs.hotkey.bind({"shift", "cmd"}, "g", fn)
