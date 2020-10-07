--- === Dash ===
---
--- Dash (version 5 of later) automations.
local Hotkey = require("hs.hotkey")
local ui = require("rb.ui")

local obj = {}

obj.__index = obj
obj.name = "Dash"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "com.kapeli.dashdoc"

local _modal = nil
local _appObj = nil

local function pane1(appObj)
    local _pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}}
    ui.getUIElement(appObj, _pane1):setAttributeValue("AXFocused", true)
end

local function pane2(appObj)
    local _pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}}
    ui.getUIElement(appObj, _pane2):setAttributeValue("AXFocused", true)
end

local function clickOnHistoryMenuItem(appObj)
    appObj:selectMenuItem({"History"})
end

local function toggleBookmarks(appObj)
    if appObj:selectMenuItem({"Bookmarks", "Show Bookmarks..."}) then
        return
    end
    appObj:selectMenuItem({"Bookmarks", "Hide Bookmarks"})
end

local hotkeys = {
    {
        "alt",
        "1",
        function()
            pane1(_appObj)
        end
    },
    {
        "alt",
        "2",
        function()
            pane2(_appObj)
        end
    },
    {
        "cmd",
        "y",
        function()
            clickOnHistoryMenuItem(_appObj)
        end
    },
    {
        {"alt", "cmd"},
        "b",
        function()
            toggleBookmarks(_appObj)
        end
    }
}

function obj:start(appObj)
    _appObj = appObj
    _modal:enter()
    return self
end

function obj:stop()
    _modal:exit()
    return self
end

function obj:init()
    if not obj.bundleID then
        hs.showError("bundle indetifier for app spoon is nil")
    end
    _modal = Hotkey.modal.new()
    for _, v in ipairs(hotkeys) do
        _modal:bind(table.unpack(v))
    end
    return self
end

return obj
