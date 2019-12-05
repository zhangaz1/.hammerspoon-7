local PathWatcher = require("hs.pathwatcher")
local Task = require("hs.task")
local FS = require("hs.fs")

local obj = {}

obj.__index = obj
obj.name = "DownloadsListener"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.pathWatcher = nil

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local home = os.getenv("HOME")

obj.spoonPath = script_path()

function obj:init()
  self.pathWatcher = PathWatcher.new(home .. "/Downloads", self.patchWatcherCallbackFn)
end

function obj:start()
  self.pathWatcher:start()
end

function obj.patchWatcherCallbackFn(paths, flagTables)
  -- print(hs.inspect(paths))
  -- print(hs.inspect(flagTables))
  for i, path in ipairs(paths) do
    if flagTables[i].itemCreated then
      -- PROCESS THE FILES
      local fileName = FS.displayName(path)
      -- uncompress and trash .zips
      if path:sub(-4) == ".zip" then
        local targetDir, _ = string.gsub(path, "%.zip$", "")
        FS.mkdir(targetDir)
        Task.new(
          "/usr/bin/ditto",
          function()
            os.rename(path, home .. "/.Trash/" .. fileName)
          end,
          {"-xk", path, targetDir}
        ):start()
      --
      end
    end
  end
end

return obj
