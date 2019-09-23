local fs = require("hs.fs")

local mod = {}

local appEnvs = {}

-- REQUIRE APP SCRIPTS
-- function mod.loadLuaFiles()
    local iterFn, dirObj = fs.dir('./apps')
    if iterFn then
        for file in iterFn, dirObj do
            if file:sub(-4) == ".lua" then
                local name, _ = file:gsub('.lua', '')
                table.insert( appEnvs, require('/apps/' .. name))
            end
        end
    end
-- end

-- LOAD APP SCRIPTS INTO THE TABLE
function mod.loadAppScripts(forApplication)
	local output = {}
	for _, v in ipairs(appEnvs) do
		if v.id == forApplication:bundleID() then
			if v.appScripts then
				for index, script in ipairs(v.appScripts) do
					local item = {
						text = script.title,
						subText = 'Application Script',
						path = {'Application Scripts', script.title},
						index = index,
						type = 'appScript',
						id = v.id
					}
					table.insert(output, item)
				end
			end
		end
	end
	return output
end

function mod.executeScript(forApplication, scriptIndex)
    for _,v in ipairs(appEnvs) do
        if v.id == forApplication:bundleID() then
            v.thisApp = forApplication
            v.appScripts[scriptIndex].func()
        end
    end
end

return mod
