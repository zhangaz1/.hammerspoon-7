local ui = require("rb.ui")
local AppleScript = require("hs.osascript").applescript

local obj = {}

obj.id = "com.apple.Preview"

function obj.pane1(appObj)
  local pane1 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 1}, {"AXList", 1}}
  ui.getUIElement(appObj, pane1):setAttributeValue("AXFocused", true)
end

function obj.pane2(appObj)
  local pane2 = {{"AXWindow", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}, {"AXGroup", 1}}
  ui.getUIElement(appObj, pane2):setAttributeValue("AXFocused", true)
end

function obj.goToFirstPage()
  AppleScript([[tell application "System Events" to tell application process "Preview"
    click menu item "Go to Page…" of menu 1 of menu bar item "Go" of menu bar 1
    delay 0.2
    keystroke "1"
    delay 0.1
    key code 36 -- return
  end tell]])
end

function obj.goToLastPage()
  AppleScript([[tell application "System Events" to tell application process "Preview"
    set lastPageNum to last word of (name of window 1 as text)
    click menu item "Go to Page…" of menu 1 of menu bar item "Go" of menu bar 1
    delay 0.2
    keystroke lastPageNum
    delay 0.1
    key code 36
  end tell]])
end

return obj
