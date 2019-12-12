local hs = hs
local PathWatcher = require("hs.pathwatcher")
local Task = require("hs.task")
local FS = require("hs.fs")
local Notify = require("hs.notify")
local Fnutils = require("hs.fnutils")

local obj = {}

obj.__index = obj
obj.name = "DownloadsWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()

obj.eventTime = nil
obj.pathWatcher = nil

local home = os.getenv("HOME")
local downloadsDir = home .. "/Downloads"

local function tableCount(t)
  local n = 0
  for _, _ in pairs(t) do
    n = n + 1
  end
  return n
end

local function newFilesNotification(paths)
  Notify.new(
    function(arg)
      local activationType = arg:activationType()
      if Notify.activationTypes[activationType] == "additionalActionClicked" then
        local chosenAction = arg:additionalActivationAction()
        local bin
        local opts
        if chosenAction == "Open" then
          bin = "/usr/bin/open"
          opts = {}
          paths = {paths[1]}
        elseif chosenAction == "Reveal" then
          bin = "/usr/bin/open"
          opts = {"-R"}
          paths = {paths[1]}
        end
        local args = Fnutils.concat(opts, paths)
        return Task.new(bin, nil, args):start()
      end
    end,
    {
      title = "DownloadsWatcher",
      informativeText = string.format("%s new file(s)", tableCount(paths)),
      hasActionButton = true,
      actionButtonTitle = "Actions",
      additionalActions = {"Open", "Reveal", "Quick Look", "LaunchBar"}
    }
  ):withdrawAfter(10):send()
end

function obj:init()
  self.pathWatcher = PathWatcher.new(downloadsDir, self.patchWatcherCallbackFn)
end

function obj:start()
  self.pathWatcher:start()
end

local function shouldProcessPath(path)
  local displayName = FS.displayName(path)
  -- ignore deleted files
  if displayName == nil then
    return
  end
  -- ignore misc files
  local escapedDisplayName = displayName:gsub("%p", "%%%1")
  local parentDir, _ = path:gsub(escapedDisplayName, "")
  if displayName:match("%.download/?$") or displayName == ".DS_Store" then
    return
  end
  -- ignore changes in subdirs
  if parentDir ~= downloadsDir and parentDir ~= downloadsDir .. "/" then
    return
  end
  -- ignore renames, openings
  local diff = obj.eventTime - FS.attributes(path, "creation")
  if diff > 1 then
    return
  end
  return true
end

function obj.patchWatcherCallbackFn(paths, flagTables)
  print(hs.inspect(paths), hs.inspect(flagTables))
  obj.eventTime = os.time()
  local pathsToUse = {}
  for i, path in ipairs(paths) do
    if shouldProcessPath(path, flagTables[i]) then
      table.insert(pathsToUse, path)
      print(path)
    end
  end

  for i, path in ipairs(pathsToUse) do
    -- uncompress and trash .zips
    if path:sub(-4) == ".zip" then
      table.remove(pathsToUse, i)
      local targetDir, _ = string.gsub(path, "%.zip$", "")
      FS.mkdir(targetDir)
      Task.new(
        "/usr/bin/ditto",
        function()
          os.rename(path, home .. "/.Trash/" .. FS.displayName(path))
          -- newFilesNotification(pathsToUse)
        end,
        {"-xk", path, targetDir}
      ):start()
    end
  end
  if tableCount(pathsToUse) > 0 then
    newFilesNotification(pathsToUse)
  end
end

return obj

-- local function mdlsquery(path, attr)
--   local result, _, _ = hs.execute(string.format([["/usr/bin/mdls" "-name" "%s" "-raw" "%s"]], attr, path))
--   return result
-- end
  -- local lastDownloadedDate =
  --   mdlsquery(path, "kMDItemDownloadedDate"):match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d %+%d%d%d%d")
  -- local lastUsedDate = mdlsquery(path, "kMDItemLastUsedDate")
  -- ignoring openings
  -- if lastUsedDate ~= lastDownloadedDate then
  --   return
  -- end
-- local function toEpochDate(dateString)
--   local _, _, year, month, day, hour, minute, second = dateString:find("(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)")
--   return os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = second})
-- end
