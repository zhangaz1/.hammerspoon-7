--- === AppQuitter ===
---
--- Leverages `launchd` to quit and/or hide inactive apps in 10-minute intervals.
---
--- DO NOT activate this module if you don't plan on using it along with `hs.application.watcher`,
--- this module relies on it exclusively to update its scheduled actions as apps go in and out of focus.
--- Without it, the timers will quickly go out of sync.
--- You should call this module's `update` method with each callback of `hs.application.watcher`.

local Application = require("hs.application")
local FS = require("hs.fs")
local Plist = require("hs.plist")
local Timer = require("hs.timer")
local JSON = require("hs.json")
local FnUtils = require("hs.fnutils")
local applescript = require("hs.osascript").applescript
-- local hs = hs

local obj = {}
local rules = {}
local blacklist = nil
local DEFAULT_QUIT_INTERVAL = 14400 -- 4 hours
local DEFAULT_HIDE_INTERVAL = 600 --- 10 minutes
local TIMERS_PLIST_PATH = os.getenv("HOME") .. "/Library/Preferences/com.rb.hs.appquitter.tracker.plist"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local function startTimersForBackgroundLaunchedOrDeactivatedApp(bundleID)
  -- the sole purpose of this function is to start/update the timer
  -- when an app is deactivated or launched (in the background).
  local now = os.time()
  local timersPlist = Plist.read(TIMERS_PLIST_PATH) or {}
  local quitInterval = now + DEFAULT_QUIT_INTERVAL
  local hideInterval = now + DEFAULT_HIDE_INTERVAL
  if rules[bundleID] then
    quitInterval = now + rules[bundleID]["quit"]
    hideInterval = now + rules[bundleID]["hide"]
  end
  if not timersPlist[bundleID] then
    timersPlist[bundleID] = {}
  end
  timersPlist[bundleID] = {
    quit = quitInterval,
    hide = hideInterval
  }
  Plist.write(TIMERS_PLIST_PATH, timersPlist)
end

--- AppQuitter:update(event, bundleID)
--- Method
--- Updates the module's timers.
---
--- Parameters:
---  * event - A string, one of the `hs.application.watcher` event constants.
---  * bunldeID - A string, the bundle indetifier of event-triggering app.
function obj:update(event, bundleID)
  -- bail out if app is blacklisted
  if FnUtils.contains(blacklist, bundleID) then
    return
  end
  if event == Application.watcher.deactivated or event == Application.watcher.launched then
    startTimersForBackgroundLaunchedOrDeactivatedApp(bundleID)
  end
end

--- AppQuitter:start()
--- Method
--- Sets up and starts the module. Begins the tracking of running dock apps,
--- or resumes tracking of a given app if its timer is already running.
function obj:start()
  local launchdRunInterval = 600 --- 10 minutes
  -- local launchdRunInterval = 60 --- 10 minutes
  local launchdLabel = "com.rb.hs.appquitter.daemon"
  local launchdPlistPath = os.getenv("HOME") .. "/Library/LaunchAgents/" .. launchdLabel .. ".plist"
  local launchdPlistObject = {
    Label = launchdLabel,
    StartInterval = tonumber(launchdRunInterval),
    ProgramArguments = {
      "/usr/local/bin/hs",
      "-P",
      "/usr/local/bin/appquitter"
    },
    StandardErrorPath = os.getenv("HOME") .. "/Library/Logs/com.rb.hs.appquitter.errors.log",
    StandardOutPath = os.getenv("HOME") .. "/Library/Logs/com.rb.hs.appquitter.log"
  }

  local launchdPlistExists = FS.displayName(launchdPlistPath) ~= nil

  local shouldUpdateLaunchdPlist = false
  if launchdPlistExists then
    local currentPlist = Plist.read(launchdPlistPath)
    for property, _ in pairs(launchdPlistObject) do
      if launchdPlistObject[property] ~= currentPlist[property] then
        shouldUpdateLaunchdPlist = true
        os.execute(string.format([[/bin/launchctl unload "%s"]], launchdPlistPath))
        break
      end
    end
  end

  if not launchdPlistExists or shouldUpdateLaunchdPlist then
    Plist.write(launchdPlistPath, launchdPlistObject)
  end

  -- tracker plist
  local secsSinceBoot = Timer.absoluteTime() * (10 ^ -9)
  local shouldCleanUp = secsSinceBoot < 50
  if not FS.displayName(TIMERS_PLIST_PATH) or shouldCleanUp then
    Plist.write(TIMERS_PLIST_PATH, {})
  end

  -- python script
  -- local pyScriptDst = "/usr/local/bin/appquitter"
  -- os.remove(pyScriptDst)
  -- FS.link(script_path() .. "appquitter.py", pyScriptDst, true)
  -- launchd script
  local launchdScriptDst = "/usr/local/bin/appquitter"
  os.remove(launchdScriptDst)
  FS.link(script_path() .. "launchd.lua", launchdScriptDst, true)

  -- load rules from json
  local rulesJSON = JSON.read(script_path() .. "/rules.json")
  for bundleid, rulesTable in pairs(rulesJSON["apps"]) do
    for operation, time in pairs(rulesTable) do
      if not rules[bundleid] then
        rules[bundleid] = {}
      end
      rules[bundleid][operation] = time * (60 * 60) -- convert hours to seconds
    end
  end
  -- load blacklist
  blacklist = rulesJSON["blacklist"]

  local stdout, _, _, _ = hs.execute("/bin/launchctl list")
  local isJobLoaded = string.match(stdout, launchdLabel)
  if not isJobLoaded then
    os.execute(string.format([[/bin/launchctl load "%s"]], launchdPlistPath))
  end

  -- start tracking running apps
  local _, dockApps, _ = applescript [[tell application "System Events" to return the bundle identifier of every application process whose background only is false]]
  local timersPlist = Plist.read(TIMERS_PLIST_PATH) or {}
  local appsWithRunningTimers = {}
  for appID, _ in pairs(timersPlist) do
    table.insert(appsWithRunningTimers, appID)
  end
  for _, appID in ipairs(dockApps) do
    if not FnUtils.contains(blacklist, appID) and not FnUtils.contains(appsWithRunningTimers, appID) then
      -- unless they're unless their blacklisted
      -- dont overwrite apps with running timers
      startTimersForBackgroundLaunchedOrDeactivatedApp(appID)
    end
  end
end

--- AppQuitter:init()
--- Method
--- Initializes the module.
function obj:init()
end

return obj
