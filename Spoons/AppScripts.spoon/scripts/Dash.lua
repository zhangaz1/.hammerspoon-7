local ui = require("rb.ui")

local obj = {}

-- supports Dash 5 or later
obj.id = "com.kapeli.dashdoc"

function obj.pane1(appObj)
  local pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}}
  ui.getUIElement(appObj, pane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
  local pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}}
  ui.getUIElement(appObj, pane2):setAttributeValue("AXFocused", true)
end

function obj.clickOnHistoryMenuItem(appObj)
  appObj:selectMenuItem({"History"})
end

function obj.toggleBookmarks(appObj)
  if appObj:selectMenuItem({"Bookmarks", "Show Bookmarks..."}) then
    return
  end
  appObj:selectMenuItem({"Bookmarks", "Hide Bookmarks"})
end

return obj
