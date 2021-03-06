local ax = require("hs.axuielement")
local Hotkey = require("hs.hotkey")
local hs = hs

local obj = {}

obj.__index = obj
obj.name = "ActionEditor"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local _modal = nil
local _appObj = nil

obj.bundleID = "at.obdev.LaunchBar.ActionEditor"

local function pane1(appObj)
  ax.windowElement(appObj:focusedWindow()):searchPath({
    {role = "AXGroup"},
    {role = "AXSplitGroup"},
    {role = "AXScrollArea"},
    {role = "AXOutline"}
  }):setAttributeValue("AXFocused", true)
end

local function pane2(appObj)
  ax.windowElement(appObj:focusedWindow()):searchPath({
    {role = "AXGroup"},
    {role = "AXSplitGroup"},
    {role = "AXGroup"},
    {role = "AXScrollArea"},
    {role = "AXTextField"}
  }):setAttributeValue("AXFocused", true)
end

local functions = {pane1 = function() pane1(_appObj) end, pane2 = function() pane2(_appObj) end}

function obj:bindModalHotkeys(hotkeysTable)
  for k, v in pairs(functions) do
    if hotkeysTable[k] then
      -- print(hs.inspect(v))
      local mods, key = table.unpack(hotkeysTable[k])
      _modal:bind(mods, key, v)
    end
  end
  return self
end

function obj:start(appObj)
  _appObj = appObj
  _modal:enter()
  return self
end

function obj:stop()
  _modal:exit()
  return self
end

function obj:init()
  if not obj.bundleID then
    hs.showError("bundle indetifier for app spoon is nil")
  end
  _modal = Hotkey.modal.new()
  return self
end

return obj
