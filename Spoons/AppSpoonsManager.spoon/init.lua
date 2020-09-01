local obj = {}

obj.__index = obj
obj.name = "AppSpoonsManager"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:update(appObj, bundleID)
  for spoonName, spoonContents in pairs(spoon) do
    if spoonContents.bundleID and spoonContents.bundleID == bundleID then
      spoon[spoonName]:start(appObj)
    elseif spoonContents.bundleID then
      spoon[spoonName]:stop()
    end
  end
end

function obj:init()
end

return obj
