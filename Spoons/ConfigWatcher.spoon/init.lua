local hs = hs
local PathWatcher = require("hs.pathwatcher")

local obj = {}

obj.__index = obj
obj.name = "ConfigWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function patchWatcherCallbackFn(files, flagTables)
  local doReload = false
  for i, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      if flagTables[i].itemModified or flagTables[i].itemCreated or flagTables[i].itemRenamed then
        doReload = true
        break
      end
    end
  end
  if doReload then
    hs.reload()
  end
end

obj.pathWatcher = nil

function obj:init()
  self.pathWatcher = PathWatcher.new(".", patchWatcherCallbackFn)
end

function obj:start()
  self.pathWatcher:start()
end

return obj
