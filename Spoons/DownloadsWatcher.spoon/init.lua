local PathWatcher = require("hs.pathwatcher")
local Task = require("hs.task")
local FS = require("hs.fs")
local Fnutils = require("hs.fnutils")
local Settings = require("hs.settings")
local Timer = require("hs.timer")

local obj = {}

local processedDownloadsInodesKey = settingKeys.processedDownloadsInodes

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
obj.spoonPath = script_path()

local home = os.getenv("HOME")
local downloadsDir = home .. "/Downloads"
local shellScript = obj.spoonPath .. "/process_path.sh"
local filesToIgnore = {".DS_Store", ".localized", ".", ".."}

obj.pathWatcher = nil
obj.lastPathsDetected = {}
obj.lastFlagTables = {}
obj.ProcessedDownloadsInodes = {}
obj.delayedTimer = nil

local dirIsEmpty

local function delayedTimerCallbackFn()
  local iteratedFiles = {}
  local pathsToProcess = {}
  local iterFn, dirObj = FS.dir(downloadsDir)
  if iterFn then
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
  else
    print(string.format("DownloadsWatcher enumerator error: %s", dirObj))
  end
  local newPlistSetting = obj.ProcessedDownloadsInodes
  if tableCount(iteratedFiles) == 0 then
    -- dirIsEmpty = true
    print("DownloadsWatcher: ~/Downloads emptied, clearing inodes list")
    newPlistSetting = {}
  end
  Settings.set(processedDownloadsInodesKey, newPlistSetting)
  for _, path in ipairs(pathsToProcess) do
    Task.new(
      shellScript,
      function(_, _, err)
        print("DownloadsWatcher error: ", err)
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
