local Application = require("hs.application")
local FS = require("hs.fs")
local MenuBar = require("hs.menubar")
local Settings = require("hs.settings")
local KeyCodes = require("hs.keycodes")

local obj = {}

obj.__index = obj
obj.name = "AppWatcher"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.appEnvs = {}
obj.spoonPath = script_path()
obj.appwatcher = nil
obj.hebrewMenubarItem = nil

local function currentState()
  return Settings.get("forceABC")
end

local function keepState(appObj)
  if currentState() == "enabled" then
    if appObj and appObj:bundleID() == "desktop.WhatsApp" then
      KeyCodes.setLayout("Hebrew")
    else
      KeyCodes.setLayout("ABC")
    end
    obj.hebrewMenubarItem:removeFromMenuBar()
  else
    obj.hebrewMenubarItem:returnToMenuBar():setTitle("HEB")
  end
end

function obj.toggleState()
  if currentState() == "enabled" then
    Settings.set("forceABC", "disabled")
  elseif currentState() == "disabled" then
    Settings.set("forceABC", "enabled")
  end
  keepState()
end

-- app watcher callBack
local function appWatcherCallback(_, event, appObj)
  if (event == Application.watcher.activated) then
    -- BEGIN HEBREW-RELATED
    keepState(appObj)
    -- END HEBREW-RELATED
    local id = appObj:bundleID()
    for _, appEnv in ipairs(obj.appEnvs) do
      local modal = appEnv.modal
      local listeners = appEnv.listeners
      if appEnv.id == id then
        appEnv.thisApp = appObj
        if modal then
          modal:enter()
        end
        if listeners then
          for _, listener in ipairs(listeners) do
            listener:start()
          end
        end
      else
        if modal then
          modal:exit()
        end
        if listeners then
          for _, listener in ipairs(listeners) do
            listener:stop()
          end
        end
      end
    end
  end
end

function obj:init()
  self.hebrewMenubarItem = MenuBar.new()
  -- initialize if not previously set, default to enabled
  if not currentState() then
    Settings.set("forceABC", "enabled")
  end
  keepState()
  -- load individual app modules into the appEnvs table
  local appModulesDir = self.spoonPath .. "/apps"
  local iterFn, dirObj = FS.dir(appModulesDir)
  if iterFn then
    for file in iterFn, dirObj do
      if file:sub(-4) == ".lua" then
        table.insert(self.appEnvs, dofile(appModulesDir .. "/" .. file))
      end
    end
  end
  -- create the watcher and start
  self.appwatcher = Application.watcher.new(appWatcherCallback):start()
  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
end

return obj
