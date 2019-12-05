local hs = hs
local HSPathWatcher = require("hs.pathwatcher")

local mod = {}

local function patchWatcherCallbackFn(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

pathWatcher = HSPathWatcher.new(".", patchWatcherCallbackFn)

function mod.init()
    pathWatcher:start()
end

return mod
