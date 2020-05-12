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

obj.RULES = nil

local minute = 60
-- local hour = 60 * minute
local LAUNCHD_RUN_INTERVAL = 10 * minute
local LAUNCHD_LABEL = "com.rb.hs.appquitter.daemon"
local LAUNCHD_PLIST = os.getenv("HOME") .. "/Library/LaunchAgents/" .. LAUNCHD_LABEL .. ".plist"
local PREFS_PLIST_PATH = os.getenv("HOME") .. "/Library/Preferences/com.rb.hs.appquitter.tracker.plist"
local PYTHON_SCRIPT = script_path() .. "/appquitter.py"

local plistObj = {
  Label = LAUNCHD_LABEL,
  StartInterval = tonumber(LAUNCHD_RUN_INTERVAL),
  ProgramArguments = {
    "/usr/local/bin/appquitter"
  },
  StandardErrorPath = "/Users/roey/Desktop/err.txt",
  StandardOutPath = "/Users/roey/Desktop/out.txt"
}

local function isJobLoaded(label)
  local stdout, _, _, _ = hs.execute("/bin/launchctl list")
  if string.match(stdout, label) then
    return true
  end
end

function obj:stopTimersForActivatedOrTerminatedApp(bundleID)
  if not obj.RULES[bundleID] then
    return
  end
  local plistTable = hs.plist.read(PREFS_PLIST_PATH)
  if not plistTable[bundleID] then
    return
  end
  for k, v in pairs(plistTable[bundleID]) do
    local val
    if k == "id" then
      val = v
    elseif string.match(k, "_DEBUG") then
      val = ""
    else
      val = 0
    end
    plistTable[bundleID][k] = val
  end
  hs.plist.write(PREFS_PLIST_PATH, plistTable)
end

function obj:startTimerForLaunchedOrDeactivatedApp(bundleID)
  if not obj.RULES[bundleID] then
    return
  end
  local plistTable = hs.plist.read(PREFS_PLIST_PATH) or {}
  -- init with zeroes
  if not plistTable[bundleID] then
    plistTable[bundleID] = {}
  end
  for action, interval in pairs(obj.RULES[bundleID]) do
    local currentIntervalValue = plistTable[bundleID][action]
    -- only update zeroed timers, to not override running ones
    if currentIntervalValue == nil or currentIntervalValue == 0 then
      local now = os.time()
      plistTable[bundleID][action] = now + interval
      plistTable[bundleID].id = bundleID
      local date = os.date("*t", now + interval)
      date = string.format("%s:%s %s-%s-%s", date.hour, date.min, date.year, date.month, date.day)
      plistTable[bundleID][action .. "_DEBUG"] = date
    end
  end
  hs.plist.write(PREFS_PLIST_PATH, plistTable)
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
  obj.RULES = dofile(script_path() .. "/appquitter_rules.lua")
  -- launchd plist
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

  -- tracker plist
  if not hs.fs.displayName(PREFS_PLIST_PATH) then
    hs.plist.write(PREFS_PLIST_PATH, {})
  end

  if not hs.fs.displayName("/usr/local/bin/appquitter") then
    hs.fs.link(PYTHON_SCRIPT, "/usr/local/bin/appquitter", true)
  end

  local runningApps = hs.application.runningApplications()
  for _, v in ipairs(runningApps) do
    if not v:isFrontmost() then
      for id, _ in pairs(obj.RULES) do
        if v:bundleID() == id then
          obj:startTimerForLaunchedOrDeactivatedApp(id)
          break
        end
      end
    end
  end
end

return obj
