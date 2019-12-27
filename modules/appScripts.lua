local application = require("hs.application")
local GlobalChooser = require("util.GlobalChooser")
local Image = require("hs.image")

local obj = {}

local function chooserCallback(choice)
    spoon.AppWatcher.appEnvs[choice.appEnvIndex].appScripts[choice.funcIndex]
        .func()
end

function obj:start()
		local frontApp = application:frontmostApplication()
		local frontAppID = frontApp:bundleID()
    local choices = {}
    for appEnvIndex, file in ipairs(spoon.AppWatcher.appEnvs) do
        if file.id == frontAppID then
            if file.appScripts then
                for funcIndex, script in ipairs(file.appScripts) do
                    table.insert(choices, {
                        text = script.title,
                        subText = "Application Script",
                        funcIndex = funcIndex,
												appEnvIndex = appEnvIndex,
												image = Image.imageFromAppBundle(frontAppID)
                    })
                end
            end
            break
        end
    end
    GlobalChooser:start(chooserCallback, choices, {"text"})
end

return obj
