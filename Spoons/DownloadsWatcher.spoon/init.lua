--- === DownloadsWatcher ===
--- Monitor the ~/Downloads folder, and execute a shell script that accepts newly downloaded files as arguments.
--- The script can be found in the Spoon's folder.
local PathWatcher = require("hs.pathwatcher")
local Task = require("hs.task")
local FS = require("hs.fs")
local Fnutils = require("hs.fnutils")
local Settings = require("hs.settings")
local Timer = require("hs.timer")
local Pasteboard = require("hs.pasteboard")
local spoon = spoon

local obj = {}

obj.__index = obj
obj.name = "DownloadsWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function tableCount(t)
  local n = 0
  for _, _ in pairs(t) do
    n = n + 1
  end
  return n
end

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local processedDownloadsInodesKey = "RBDownloadsWatcherProcessedDownloadsInodes"
local home = os.getenv("HOME")
local downloadsDir = home .. "/Downloads"
local shellScript = script_path() .. "/process_path.sh"
local filesToIgnore = {".DS_Store", ".localized", ".", ".."}
local processedDownloadsInodes = {}
local pathWatcher
local delayedTimer

local function pathWatcherCallbackFn()
  delayedTimer:start()
end

local function delayedTimerCallbackFn()
  local iteratedFiles = {}
  local pathsToProcess = {}
  local iterFn, dirObj = FS.dir(downloadsDir)
  if not iterFn then
    print(string.format("DownloadsWatcher FS.dir enumerator error: %s", dirObj))
    return
  end
  for file in iterFn, dirObj do
    if not Fnutils.contains(filesToIgnore, file) then
      if not file:match("%.download/?$") then
        local fullPath = downloadsDir .. "/" .. file
        local inode = FS.attributes(fullPath, "ino")
        if not Fnutils.contains(processedDownloadsInodes, inode) then
          table.insert(processedDownloadsInodes, inode)
          table.insert(pathsToProcess, fullPath)
        end
        table.insert(iteratedFiles, file)
      end
    end
  end
  local newPlistSetting = processedDownloadsInodes
  if tableCount(iteratedFiles) == 0 then
    print("DownloadsWatcher: ~/Downloads emptied, clearing inodes list")
    newPlistSetting = {}
  end
  Settings.set(processedDownloadsInodesKey, newPlistSetting)
  -- local collectedPaths = {}
  for _, path in ipairs(pathsToProcess) do
    spoon.StatusBar.progress.start()
    Task.new(
      shellScript,
      function(_, stdout, stderr)
        if string.match(stderr, "%s+") then
          print("DownloadsWatcher shell script stderr: ", stderr)
        end
        Pasteboard.setContents(stdout)
        spoon.StatusBar.progress.stop()
      end,
      {path}
    ):start()
  end
end

--- DownlodasWatcher:stop()
--- Method
--- Stops the module.
function obj.start()
  pathWatcher:start()
end

--- DownlodasWatcher:start()
--- Method
--- Starts the module.
function obj.start()
  pathWatcher:start()
end

function obj.init()
  delayedTimer = Timer.delayed.new(1, delayedTimerCallbackFn)
  processedDownloadsInodes = Settings.get(processedDownloadsInodesKey)
  pathWatcher = PathWatcher.new(downloadsDir, pathWatcherCallbackFn)
end

return obj
