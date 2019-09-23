local hotkey = require('hs.hotkey')
local osascript = require('hs.osascript')
local ui = require("util.ui")

local m = {}
m.id = 'com.apple.Preview'
m.thisApp = nil
m.modal = hotkey.modal.new()

local uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}} --, {'AXList', 1}}
local uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}} --, {'AXGroup', 1}}

local function pane1()
  ui.getUIElement(m.thisApp, uiPane1):setAttributeValue('AXFocused', true)
end

local function pane2()
  ui.getUIElement(m.thisApp, uiPane2):setAttributeValue('AXFocused', true)
end

local function goToFirstPage()
  osascript.applescript([[tell application "System Events" to tell application process "Preview"
    click menu item "Go to Page…" of menu 1 of menu bar item "Go" of menu bar 1
    delay 0.2
    keystroke "1"
    delay 0.1
    key code 36 -- return
  end tell]])
end

local function goToLastPage()
  osascript.applescript([[tell application "System Events" to tell application process "Preview"
    set lastPageNum to last word of (name of window 1 as text)
    click menu item "Go to Page…" of menu 1 of menu bar item "Go" of menu bar 1
    delay 0.2
    keystroke lastPageNum
    delay 0.1
    key code 36
  end tell]])
end

m.appScripts = {
  {title = 'Go to First Page', func = function() goToFirstPage() end},
  {title = 'Go to Last Page', func = function() goToLastPage() end}
}

m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)

return m
