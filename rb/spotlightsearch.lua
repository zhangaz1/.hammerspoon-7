-- TESTS
local Spotlight = require("hs.spotlight")
local Chooser = require("hs.chooser")
local Image = require("hs.image")
local Timer = require("hs.timer")

local obj = {}

obj.chooser = nil
obj.spotlight = nil

local function chooserCallback()
  obj.spotlight:stop()
end

local function searchCompleteCallback(spotlightObject, message)
  if message ~= "didFinish" then
    return
  end
  local items = {}
  for _, v in ipairs(spotlightObject) do
    local item = {
      text = v.kMDItemDisplayName,
      subText = v.kMDItemPath
    }
    if v.kMDItemPath then
      item.image = Image.iconForFile(v.kMDItemPath)
    end
    table.insert(items, item)
  end
  obj.chooser:choices(items)
end

local function spotlightSearch(searchQuery)
  if searchQuery == "" or searchQuery == false then
    obj.chooser:choices({})
    obj.spotlight:stop()
    return
  end
  Timer.delayed.new(
    0.2,
    function()
      obj.spotlight:queryString(string.format([[ kMDItemDisplayName LIKE[cd] "%s*" ]], searchQuery))
      if not obj.spotlight:isRunning() then
        obj.spotlight:start()
      end
    end
  ):start()
end

function obj:init()
  obj.chooser =
    Chooser.new(chooserCallback):queryChangedCallback(
    function()
      spotlightSearch(obj.chooser:query())
    end
  ):width(25)
  obj.spotlight = Spotlight.new():searchScopes(Spotlight.definedSearchScopes):setCallback(searchCompleteCallback)
end

function obj:start()
  obj.chooser:show()
end

return obj
