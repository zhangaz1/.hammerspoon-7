-- https://alvinalexander.com/mac-os-x/launchd-plist-examples-startinterval-startcalendarinterval/
-- https://apple.stackexchange.com/questions/29056/launchctl-difference-between-load-and-start-unload-and-stop/308421

local Application = require("hs.application")
local FS = require("hs.fs")
local Plist = require("hs.plist")
local spoon = spoon
local hs = hs

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

obj.RULES = nil
-- obj.appWatcher = nil

local minute = 60
-- local hour = 60 * minute
local LAUNCHD_RUN_INTERVAL = 10 * minute
local LAUNCHD_LABEL = "com.rb.hs.appquitter.daemon"
local LAUNCH_AGENT_PLIST = os.getenv("HOME") .. "/Library/LaunchAgents/" .. LAUNCHD_LABEL .. ".plist"
local TIMERS_PLIST = os.getenv("HOME") .. "/Library/Preferences/com.rb.hs.appquitter.tracker.plist"
local PYTHON_SCRIPT = script_path() .. "/appquitter.py"

local LAUNCH_AGENT_PLIST_OBJ = {
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
  local timersPlist = Plist.read(TIMERS_PLIST)
  if not timersPlist[bundleID] then
    return
  end
  for key, _ in pairs(timersPlist[bundleID]) do
    if key ~= "id" then
      timersPlist[bundleID][key] = 0
    end
  end
  Plist.write(TIMERS_PLIST, timersPlist)
end

function obj:stopTimersForHiddenApp(bundleID)
  if not obj.RULES[bundleID] then
    return
  end
  local timersPlist = Plist.read(TIMERS_PLIST)
  if not timersPlist[bundleID] then
    return
  end
  for key, _ in pairs(timersPlist[bundleID]) do
    if key == "hide" then
      timersPlist[bundleID][key] = 0
    end
  end
  Plist.write(TIMERS_PLIST, timersPlist)
end

function obj:startTimersForLaunchedOrDeactivatedApp(bundleID)
  if not obj.RULES[bundleID] then
    return
  end
  local timersPlist = Plist.read(TIMERS_PLIST) or {}
  -- init with zeroes
  if not timersPlist[bundleID] then
    timersPlist[bundleID] = {}
  end
  for action, interval in pairs(obj.RULES[bundleID]) do
    local currentIntervalValue = timersPlist[bundleID][action]
    -- only update zeroed timers, to not override running ones
    if currentIntervalValue == nil or currentIntervalValue == 0 then
      local now = os.time()
      timersPlist[bundleID][action] = now + interval
      timersPlist[bundleID].id = bundleID
    end
  end
  Plist.write(TIMERS_PLIST, timersPlist)
end

function obj:update(event, bundleID)
  if event == Application.watcher.deactivated or event == Application.watcher.launched then
    obj:startTimersForLaunchedOrDeactivatedApp(bundleID)
  end
  if event == Application.watcher.activated or event == Application.watcher.terminated then
    obj:stopTimersForActivatedOrTerminatedApp(bundleID)
  end
  if event == Application.watcher.hidden then
    obj:stopTimersForHiddenApp(bundleID)
  end
end

local function cleanup()
  print("secs since boot", hs.timer.absoluteTime() * (10^-9))
end

function obj:init()
  cleanup()

  obj.RULES = dofile(script_path() .. "/appquitter_rules.lua")
  -- launchd plist
  if not FS.displayName(LAUNCH_AGENT_PLIST) then
    Plist.write(LAUNCH_AGENT_PLIST, LAUNCH_AGENT_PLIST_OBJ)
  end

  if hs.inspect(LAUNCH_AGENT_PLIST_OBJ) ~= hs.inspect(Plist.read(LAUNCH_AGENT_PLIST)) then
    local unload = string.format([[/bin/launchctl unload "%s"]], LAUNCH_AGENT_PLIST)
    os.execute(unload)
    Plist.write(LAUNCH_AGENT_PLIST, LAUNCH_AGENT_PLIST_OBJ)
  end

  if not isJobLoaded(LAUNCHD_LABEL) then
    local load = string.format([[/bin/launchctl load "%s"]], LAUNCH_AGENT_PLIST)
    os.execute(load)
  end

  -- tracker plist
  if not FS.displayName(TIMERS_PLIST) then
    Plist.write(TIMERS_PLIST, {})
  end

  if not FS.displayName("/usr/local/bin/appquitter") then
    FS.link(PYTHON_SCRIPT, "/usr/local/bin/appquitter", true)
  end

  local runningApps = Application.runningApplications()
  for _, v in ipairs(runningApps) do
    if not v:isFrontmost() then
      for id, _ in pairs(obj.RULES) do
        if v:bundleID() == id then
          obj:startTimersForLaunchedOrDeactivatedApp(id)
          break
        end
      end
    end
  end
end

return obj
