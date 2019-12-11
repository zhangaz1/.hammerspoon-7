local Application = require("hs.application")
local FS = require("hs.fs")
local forceABC = require("modules.forceABC")

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
obj.watcher = nil

-- app watcher callBack
local function appWatcherCallback(_, event, appObj)
  if (event == Application.watcher.activated) then
    -- BEGIN HEBREW-RELATED
    forceABC.keepState(appObj)
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
  -- create the watcher
  self.watcher = Application.watcher.new(appWatcherCallback)
end

function obj:start()
    -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
    appWatcherCallback(nil, Application.watcher.activated, Application.frontmostApplication())
    -- start the path watcher
    self.watcher:start()
end

return obj
