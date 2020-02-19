local Window = require("hs.window")
local Image = require("hs.image")
local Eventtap = require("hs.eventtap")
local Hotkey = require("hs.hotkey")
local task = require("hs.task")

-- local GlobalChooser = require("util.GlobalChooser")
-- local presshold = require("util.PressAndHold")

local obj = {}

obj.__index = obj
obj.name = "WindowWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.windowFilter = nil

-- local function script_path()
--   local str = debug.getinfo(2, "S").source:sub(2)
--   return str:match("(.*/)")
-- end

-- obj.windowChooserModal = Hotkey.modal.new()

-- local function modifierKeyWatcherCallBack(event)
--   -- https://github.com/Hammerspoon/hammerspoon/issues/2167
--   if event:getFlags():containExactly({}) then
--   end
-- end

-- local function chooserCallback(choice)
--   obj.modifierKeyWatcher:stop()
--   Window.get(choice.id):focus()
-- end

-- obj.modifierKeyWatcher = Eventtap.new({Eventtap.event.types.keyUp}, modifierKeyWatcherCallBack)
-- local function modifierKeyReleased()
-- end

-- function obj:start()
--   local wins = {}
--   local visibleWindows = obj.filter:getWindows()
--   for _, win in ipairs(visibleWindows) do
--     local add = true
--     local title = win:title()
--     local app = win:application()
--     local appName = app:name()
--     local bundle = app:bundleID()
--     local id = win:id()
--     if title == "" then
--       title = nil
--       if appName == "Finder" or appName == "Safari" then
--         add = false
--       end
--     end
--     if add then
--       table.insert(wins, {text = appName, subText = title, id = id, image = Image.imageFromAppBundle(bundle)})
--     end
--   end
--   obj.modifierKeyWatcher:start()
--   GlobalChooser:start(chooserCallback, wins, {"text", "subText"}):selectedRow(2)
-- end

-- Hotkey.bind(
--   {"cmd", "alt", "shift", "ctrl"},
--   "`",
--   function()
--     presshold.onKeyDown(
--       0.2,
--       function()
--         obj:start()
--       end
--     )
--   end,
--   function()
--     presshold.onKeyUp1(
--       function()
--         obj.filter:getWindows()[2]:focus()
--       end
--     )
--   end
-- )

return obj
