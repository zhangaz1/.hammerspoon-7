local PathWatcher = require("hs.pathwatcher")
local Task = require("hs.task")
local FS = require("hs.fs")
local Fnutils = require("hs.fnutils")
local Settings = require("hs.settings")
local Timer = require("hs.timer")
local Pasteboard = require("hs.pasteboard")

local spoon = spoon
local processedDownloadsInodesKey = settingKeys.processedDownloadsInodes

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

local obj = {}

obj.__index = obj
obj.name = "DownloadsWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.spoonPath = script_path()

local home = os.getenv("HOME")
local downloadsDir = home .. "/Downloads"
local shellScript = obj.spoonPath .. "/process_path.sh"

obj.pathWatcher = nil
obj.lastPathsDetected = {}
obj.lastFlagTables = {}
obj.ProcessedDownloadsInodes = {}
obj.delayedTimer = nil

local filesToIgnore = {".DS_Store", ".localized", ".", ".."}

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
        if not Fnutils.contains(obj.ProcessedDownloadsInodes, inode) then
          table.insert(obj.ProcessedDownloadsInodes, inode)
          table.insert(pathsToProcess, fullPath)
        end
        table.insert(iteratedFiles, file)
      end
    end
  end
  local newPlistSetting = obj.ProcessedDownloadsInodes
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
        -- table.insert(collectedPaths, stdout)
        spoon.StatusBar.progress.stop()
      end,
      {path}
    ):start()
  end
end

local function pathWatcherCallbackFn()
  obj.delayedTimer:start()
end

function obj:init()
  self.delayedTimer = Timer.delayed.new(1, delayedTimerCallbackFn)
  self.pathWatcher = PathWatcher.new(downloadsDir, pathWatcherCallbackFn)
  self.ProcessedDownloadsInodes = Settings.get(processedDownloadsInodesKey)
  self.pathWatcher:start()
end

return obj
