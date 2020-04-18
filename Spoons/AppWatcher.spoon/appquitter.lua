-- https://alvinalexander.com/mac-os-x/launchd-plist-examples-startinterval-startcalendarinterval/
-- https://apple.stackexchange.com/questions/29056/launchctl-difference-between-load-and-start-unload-and-stop/308421

local Application = require("hs.application")
local Timer = require("hs.timer")
local Settings = require("hs.settings")
local Plist = require("hs.plist")
local URLEvent = require("hs.urlevent")

local hs = hs
local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

local appQuitterSupportedOperations = {"Quit", "Hide"}
local LAUNCHD_DIR = os.getenv("HOME") .. "/Library/LaunchAgents/"
local LABEL_PREFIX = "com.rb.appquitter"

obj.runningApplications = {}
obj.delayedTimer = nil

local minute = 60
local hour = 60 * minute

local appQuitterRulesTable = {
  ["at.obdev.LaunchBar.ActionEditor"] = {
    hide = 2 * minute
    -- quit = 2 * minute,
  },
  ["com.kapeli.dashdoc"] = {
    hide = 2 * minute
  },
  ["com.apple.iMovieApp"] = {
    quit = 6 * hour
  },
  ["com.latenightsw.ScriptDebugger7"] = {
    quit = 30 * minute
  }
  -- ["com.adobe.acc.AdobeCreativeCloud"] = {
  --   hide = minute
  -- },
  -- ["org.processing.app"] = {
  --   quit = 10*minute
  -- }
}

local function createLabel(id, operation)
  return string.format("%s.%s.%s", LABEL_PREFIX, id, operation)
end

local function createFile(label)
  return string.format("%s%s.plist", LAUNCHD_DIR, label)
end

local function isJobLoaded(label)
  local stdout, _, _, _ = hs.execute("/bin/launchctl list")
  if string.match(stdout, label) then
    return true
  end
  return false
end

local function unloadJob(id, operation)
  local label = createLabel(id, operation)
  local file = createFile(label)
  local s = string.format([[/bin/launchctl unload "%s"]], file)
  os.execute(s)
end

local function loadJob(id, operation)
  local label = createLabel(id, operation)
  local file = createFile(label)
  local s = string.format([[/bin/launchctl load "%s"]], file)
  os.execute(s)
end

local function invalidatePlist(id, operation)
  local label = createLabel(id, operation)
  local file = createFile(label)
  local plist = {
    Label = label
  }
  Plist.write(file, plist)
end

local function createLaunchdPlist(bundleid, operation, minutes, hours, day, month)
  local label = createLabel(bundleid, operation)
  local file = createFile(label)
  local plist = {
    Label = label,
    StartCalendarInterval = {
      Minute = tonumber(minutes),
      Hour = tonumber(hours),
      Day = tonumber(day),
      Month = tonumber(month)
    },
    ProgramArguments = {
      "/usr/bin/open",
      "-g",
      string.format("hammerspoon://appQuitterCallback?id=%s&operation=%s", bundleid, operation)
    }
  }
  Plist.write(file, plist)
end

function obj:stopTimersForActivatedOrTerminatedApp(id)
  if not appQuitterRulesTable[id] then
    return
  end
  local appRules = appQuitterRulesTable[id]
  for operationName, _ in pairs(appRules) do
    local label = createLabel(id, operationName)
    if isJobLoaded(label) then
      print("Stopping timer for", id, operationName, label)
      unloadJob(id, operationName)
      invalidatePlist(id, operationName)
    -- local file = createFile(label)
    -- os.remove(file)
    end
  end
end

function obj:startTimerForLaunchedOrDeactivatedApp(id)
  if not appQuitterRulesTable[id] then
    return
  end
  local appRules = appQuitterRulesTable[id]
  for operationName, timeInterval in pairs(appRules) do
    local label = createLabel(id, operationName)
    if isJobLoaded(label) then
      return
    end
    print("Starting timer for", label, id, operationName)
    -- if true then
    --   return
    -- end
    local nextTrigger = os.time() + timeInterval
    local minutes = os.date("%M", nextTrigger)
    local hours = os.date("%H", nextTrigger)
    local day = os.date("%d", nextTrigger)
    local month = os.date("%m", nextTrigger)
    unloadJob(id, operationName) -- discard?
    createLaunchdPlist(id, operationName, minutes, hours, day, month)
    loadJob(id, operationName)
  end
end

obj.delayedTimerEvent = nil
obj.delayedTimerBundleID = nil
local function delayedTimerCallback()
  local event = obj.delayedTimerEvent
  local id = obj.delayedTimerBundleID
  print(event, id)
  -- if (event == Application.watcher.deactivated) or (event == Application.watcher.launched) then
  --   obj.appquitter:startTimerForLaunchedOrDeactivatedApp(id)
  -- end
  -- if (event == Application.watcher.activated) or (event == Application.watcher.terminated) then
  --   obj.appquitter:stopTimersForActivatedOrTerminatedApp(id)
  -- end
end

function obj:update(event, id)
  obj.delayedTimerEvent = event
  obj.delayedTimerBundleID = id
  obj.delayedTimer:start()
end

function obj:init()
  obj.delayedTimer = Timer.delayed.new(1, delayedTimerCallback)

  local runningApplicationsBundleIDs =
    hs.fnutils.imap(
    Application.runningApplications(),
    function(x)
      return x:bundleID()
    end
  )
  for _, v in ipairs(runningApplicationsBundleIDs) do
    obj:startTimerForLaunchedOrDeactivatedApp(v)
  end
end

local function appQuitterCallback(_, params)
  local op = params.operation
  local id = params.id
  -- hs.alert(id .. " " .. op, 1)
  -- print("AppQuitterCallback", op, id)
  if Application(id) then
    if op == "quit" then
      Application(id):kill()
    else
      Application(id):hide()
    end
  end
  unloadJob(id, op)
end

URLEvent.bind("appQuitterCallback", appQuitterCallback)

return obj
