--- === HammerspoonConsole ===
--- Hammerspoon (console) automations
local Hotkey = require("hs.hotkey")
local Console = require("hs.console")

local obj = {}

obj.__index = obj
obj.name = "Hammerspoon"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.bundleID = "org.hammerspoon.Hammerspoon"

local _modal = nil

local hotkeys = {
  {"cmd", "k", function()
      Console.clearConsole()
    end},
  {"cmd", "r", function()
      hs.reload()
    end}
}

function obj:start(_)
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
