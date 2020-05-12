local hs = hs
local spoon = spoon

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local obj = {}

obj.__index = obj
obj.name = "AppScripts"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.helpers = script_path() .. "/helpers"
obj.allScripts = {}

-- local function loadAppScripts()
--   local actionsTable = dofile(script_path() .. "/app_scripts.lua")
--   for bundleID, actionList in pairs(actionsTable) do
--     obj.appActions[bundleID] = actionList
--   end
-- end

function obj:init()
  -- appquitter
  local scriptsFolder = script_path() .. "/scripts"
  local iterFn, dirObj = hs.fs.dir(scriptsFolder)
  if iterFn then
    for file in iterFn, dirObj do
      if file:sub(-4) == ".lua" then
        local appData = dofile(scriptsFolder .. "/" .. file)
        local id = appData.id
        obj.allScripts[id] = appData
      end
    end
  end
end

return obj
