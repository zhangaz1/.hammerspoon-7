local FS = require("hs.fs")

local obj = {}

obj.__index = obj
obj.name = "ApplicationScripts"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

obj.appEnvs = {}

obj.helpers = script_path() .. "/helpers"

function obj:init()
  local scriptsFolder = script_path() .. "/apps"
  local iterFn, dirObj = FS.dir(scriptsFolder)
  if iterFn then
    for file in iterFn, dirObj do
      if file:sub(-4) == ".lua" then
        local appFile = dofile(scriptsFolder .. "/" .. file)
        local id = appFile.id
        obj.appEnvs[id] = appFile
      end
    end
  end
end

return obj
