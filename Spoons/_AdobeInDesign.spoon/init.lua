--- === AdobeInDesign ===
---
--- Adobe InDesign automations.
local Hotkey = require("hs.hotkey")
local EventTap = require("hs.eventtap")

local obj = {}

obj.__index = obj
obj.name = "AdobeInDesign"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "com.adobe.InDesign"

local _modal = nil
local _appObj = nil

local hotkeys = {
    {
        "ctrl",
        "tab",
        function()
            EventTap.keyStroke("cmd", "`")
        end
    },
    {
        {"ctrl", "shift"},
        "tab",
        function()
            EventTap.keyStroke({"cmd", "shift"}, "`")
        end
    }
}

function obj:start(appObj)
    _appObj = appObj
    _modal:enter()
end

function obj:stop()
    _modal:exit()
end

function obj:init()
    if not obj.bundleID then
        hs.showError("bundle indetifier for app spoon is nil")
    end
    _modal = Hotkey.modal.new()
    for _, v in ipairs(hotkeys) do
        _modal:bind(table.unpack(v))
    end
end

return obj
