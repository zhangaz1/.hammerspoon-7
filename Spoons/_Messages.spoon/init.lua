--- === Messages ===
---
--- Messages.app automations.
local Hotkey = require("hs.hotkey")
local UI = require("rb.ui")
local Util = require("rb.util")
local fuzzyChooser = require("rb.fuzzychooser")
local hs = hs

local obj = {}
local _modal = nil
local _appObj = nil

obj.__index = obj
obj.name = "Messages"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "com.apple.iChat"

local function chooserCallback(choice)
    os.execute(string.format([["/usr/bin/open" "%s"]], choice.text))
end

local function getChatMessageLinks(appObj)
    local linkElements = UI.getUIElement(appObj:mainWindow(), {
        {"AXSplitGroup", 1}, {"AXScrollArea", 2}, {"AXWebArea", 1}
    }):attributeValue("AXLinkUIElements")
    local choices = {}
    for _, link in ipairs(linkElements) do
        local url = link:attributeValue("AXChildren")[1]:attributeValue(
                        "AXValue")
        table.insert(choices, {text = url})
    end
    if Util.tableCount(choices) == 0 then
        table.insert(choices, {text = "No Links"})
    end
    fuzzyChooser:start(chooserCallback, choices, {"text"})
end

-- TODO
obj.getMessageLinksHotkey = {"alt", "o"}

local hotkeys = {{"alt", "o", function() getChatMessageLinks(_appObj) end}}

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
    for _, v in ipairs(hotkeys) do _modal:bind(table.unpack(v)) end
    return self
end

return obj
