local MenuBar = require("hs.menubar")
-- https://www.google.com/search?client=safari&rls=en&q=pyobjc+nsstatusbar&ie=UTF-8&oe=UTF-8
-- https://github.com/jaredks/rumps
-- :start(title, input, total)
-- :update(current)
-- :finish(checkmark icon, output)

local obj = {}

obj.__index = obj
obj.name = "StatusBar"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()

local iconPath = obj.spoonPath .. "/statusicon.pdf"

obj.menuBarItem = nil

function obj:init()
  self.menuBarItem = MenuBar.new():setIcon(iconPath)
end

return obj
