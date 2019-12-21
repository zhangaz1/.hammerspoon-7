local EventTap = require("hs.eventtap")
local KeyCodes = require("hs.keycodes")

local obj = {}

obj.__index = obj
obj.name = "Emoji/Spotlight Watcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function watcherCallback(event)
  -- local space = keycodes.map[49]
  if event:getKeyCode() == 49 then
    local eventFlags = event:getFlags()
    if eventFlags:containExactly({"ctrl", "cmd"}) or eventFlags:containExactly({"alt"}) then
      if KeyCodes.currentLayout() == "ABC" then
        return
      end
      KeyCodes.setLayout("ABC")
    end
  end
end

obj.watcher = nil
-- @hebrew
-- Switch to English for Emoji & Symbols, and Spotlight
function obj:init()
  self.watcher = EventTap.new({EventTap.event.types.keyUp}, watcherCallback):start()
end

return obj
