local application = require("hs.application")
local fs = require("hs.fs")
local forceABC = require("modules.forceABC")

local mod = {}

-- load individual app modules into the appEnvs table
local appEnvs = {}
local iterFn, dirObj = fs.dir("apps")
if iterFn then
    for file in iterFn, dirObj do
        if file:sub(-4) == ".lua" then
            local name, _ = file:gsub(".lua", "")
            table.insert(appEnvs, require("apps." .. name))
        end
    end
end

local function toggleActiveModal(argForModalSwitch, hsAppObj)
    -- if called on init, hsAppObj is nil
    local id
    if not hsAppObj then
        -- if called from appWatcher, appObj is a sent argument
        hsAppObj = application.frontmostApplication()
    end
    id = hsAppObj:bundleID()
    for _, appEnv in ipairs(appEnvs) do
        if appEnv.id == id then
            if argForModalSwitch == "on" then
                appEnv.thisApp = hsAppObj
                if appEnv.modal then
                    appEnv.modal:enter()
                end
            elseif argForModalSwitch == "off" then
                if appEnv.modal then
                    appEnv.modal:exit()
                end
            end
            return
        end
    end
end

-- app watcher callBack
local function handleGlobalAppEvent(_, event, appObj)
    if (event == application.watcher.activated) then -- 5
        -- BEGIN HEBREW-RELATED
          forceABC.keepState()
        -- END HEBREW-RELATED
        toggleActiveModal("on", appObj)
    elseif (event == application.watcher.deactivated) then -- 6
        toggleActiveModal("off", appObj)
    end
end

function mod.init()
    -- activate active modal, if any -- saves an redundant cmd+tab
    toggleActiveModal("on")
    -- start the path watcher
    application.watcher.new(handleGlobalAppEvent):start()
end

return mod
