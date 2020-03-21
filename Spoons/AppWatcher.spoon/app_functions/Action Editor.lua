local ax = require("hs._asm.axuielement")

local obj = {}

obj.id = "at.obdev.LaunchBar.ActionEditor"

function obj.pane1(appObj)
  ax.windowElement(appObj:focusedWindow()):searchPath(
    {
      {role = "AXGroup"},
      {role = "AXSplitGroup"},
      {role = "AXScrollArea"},
      {role = "AXOutline"}
    }
  ):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
  ax.windowElement(appObj:focusedWindow()):searchPath(
    {
      {role = "AXGroup"},
      {role = "AXSplitGroup"},
      {role = "AXGroup"},
      {role = "AXScrollArea"},
      {role = "AXTextField"}
    }
  ):setAttributeValue("AXFocused", true)
end

return obj
