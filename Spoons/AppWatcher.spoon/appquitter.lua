-- https://alvinalexander.com/mac-os-x/launchd-plist-examples-startinterval-startcalendarinterval/
-- https://apple.stackexchange.com/questions/29056/launchctl-difference-between-load-and-start-unload-and-stop/308421

local Application = require("hs.application")
local Plist = require("hs.plist")
local hs = hs
local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

local minute = 60
local hour = 60 * minute
local RULES = {
  ["at.obdev.LaunchBar.ActionEditor"] = {
    hide = 2 * minute,
    quit = 6 * hour
  },
  ["com.kapeli.dashdoc"] = {
    hide = 2 * minute,
    quit = 6 * hour
  },
  ["com.apple.iMovieApp"] = {
    quit = 6 * hour
  },
  ["com.latenightsw.ScriptDebugger7"] = {
    quit = 6 * hour
  }
  -- ["com.adobe.acc.AdobeCreativeCloud"] = {
  --   hide = minute
  -- },
  -- ["org.processing.app"] = {
  --   quit = 10*minute
  -- }
}

local RUN_INTERVAL = 10 * minute
local LAUNCHD_LABEL = "com.rb.hs.appquitter.daemon"
local LAUNCHD_PLIST = os.getenv("HOME") .. "/Library/LaunchAgents/" .. LAUNCHD_LABEL .. ".plist"
local TRACKER_PLIST = os.getenv("HOME") .. "/Library/Preferences/com.rb.hs.appquitter.tracker.plist"
local PYTHON_SCRIPT = script_path() .. "/appquitter.py"

local plistObj = {
  Label = LAUNCHD_LABEL,
  StartInterval = tonumber(RUN_INTERVAL),
  ProgramArguments = {
    "/usr/local/bin/appquitter"
  },
  StandardErrorPath = "/Users/roey/Desktop/err.txt",
  StandardOutPath = "/Users/roey/Desktop/out.txt"
}

obj.runningApplications = {}
obj.TRACKER = {}

local function updateSettings()
  hs.plist.write(TRACKER_PLIST, obj.TRACKER)
end

local function isJobLoaded(label)
  local stdout, _, _, _ = hs.execute("/bin/launchctl list")
  if string.match(stdout, label) then
    return true
  end
end

function obj:stopTimersForActivatedOrTerminatedApp(bundleID)
  local appRules = RULES[bundleID]
  if not appRules then
    return
  end
  if not obj.TRACKER[bundleID] then
    return
  end
  for k, _ in pairs(obj.TRACKER[bundleID]) do
    obj.TRACKER[bundleID][k] = 0
  end
  updateSettings()
end

function obj:startTimerForLaunchedOrDeactivatedApp(bundleID)
  local appRules = RULES[bundleID]
  if not appRules then
    return
  end

  if not obj.TRACKER[bundleID] then
    obj.TRACKER[bundleID] = {}
  end
  for k, v in pairs(appRules) do
    local now = os.time()
    obj.TRACKER[bundleID]["should_" .. k .. "_at"] = now + v
    local date = os.date("*t", now + v)
    date = string.format("%s/%s/%s %s:%s", date.hour, date.min, date.year, date.month, date.day)
    obj.TRACKER[bundleID]["should_" .. k .. "_at_human_readable"] = date
  end
  updateSettings()
end

function obj:update(event, id)
  if (event == Application.watcher.deactivated) or (event == Application.watcher.launched) then
    obj:startTimerForLaunchedOrDeactivatedApp(id)
  end
  if (event == Application.watcher.activated) or (event == Application.watcher.terminated) then
    obj:stopTimersForActivatedOrTerminatedApp(id)
  end
end

function obj:init()
  if not hs.fs.displayName(LAUNCHD_PLIST) then
    Plist.write(LAUNCHD_PLIST, plistObj)
  end

  local launchAgent = hs.plist.read(LAUNCHD_PLIST)
  if hs.inspect(plistObj) ~= hs.inspect(launchAgent) then
    local unload = string.format([[/bin/launchctl unload "%s"]], LAUNCHD_PLIST)
    os.execute(unload)
    Plist.write(LAUNCHD_PLIST, plistObj)
  end

  if not isJobLoaded(LAUNCHD_LABEL) then
    local load = string.format([[/bin/launchctl load "%s"]], LAUNCHD_PLIST)
    os.execute(load)
  end

  if not hs.fs.displayName(TRACKER_PLIST) then
    hs.plist.write(TRACKER_PLIST, {})
  end
  obj.TRACKER = hs.plist.read(TRACKER_PLIST) or {}

  if not hs.fs.displayName("/usr/local/bin/appquitter") then
    hs.fs.link(PYTHON_SCRIPT, "/usr/local/bin/appquitter", true)
  end

  local runningApplicationsBundleIDs =
    hs.fnutils.imap(
    Application.runningApplications(),
    function(x)
      return x:bundleID()
    end
  )
  for _, v in ipairs(runningApplicationsBundleIDs) do
    if not obj.TRACKER[v] then
      obj:startTimerForLaunchedOrDeactivatedApp(v)
    end
  end
end

return obj

-- print(hs.inspect(spoon.AppWatcher.appquitter.TRACKER))
