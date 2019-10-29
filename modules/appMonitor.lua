local application = require("hs.application")
local fs = require("hs.fs")
local forceABC = require("modules.forceABC")

local mod = {}

-- load individual app modules into the appEnvs table
local appEnvs = {}
local appModulesDir = "modules/apps"
local iterFn, dirObj = fs.dir(appModulesDir)
if iterFn then
  for file in iterFn, dirObj do
    if file:sub(-4) == ".lua" then
      local name, _ = file:gsub(".lua", "")
      table.insert(appEnvs, require(appModulesDir .. "/" .. name))
    end
  end
end

-- app watcher callBack
local function appWatcherCallbackFn(_, event, appObj)
  if (event == application.watcher.activated) then
    -- BEGIN HEBREW-RELATED
    forceABC.keepState(appObj)
    -- END HEBREW-RELATED
    local id = appObj:bundleID()
    for _, appEnv in ipairs(appEnvs) do
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

function mod.init()
  -- on reload, enter modal (if any) for the front app (saves an redundant cmd+tab)
  appWatcherCallbackFn(nil, application.watcher.activated, application.frontmostApplication())
  -- start the path watcher
  appWatcher = application.watcher.new(appWatcherCallbackFn)
  appWatcher:start()
end

return mod
