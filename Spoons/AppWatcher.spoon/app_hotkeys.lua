local EventTap = require("hs.eventtap")
local Console = require("hs.console")

local hs = hs
local spoon = spoon

local function getFrontApp()
  return spoon.AppWatcher.frontApp
end

local function getActiveModal()
  return spoon.AppWatcher.activeModal
end

local function getAppEnv(app)
  return spoon.AppWatcher.appFunctions[app]
end

local obj = {
  ["com.agilebits.onepassword7"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.agilebits.onepassword7").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.agilebits.onepassword7").pane2(getFrontApp()) end},
  },
  ["at.obdev.LaunchBar.ActionEditor"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("at.obdev.LaunchBar.ActionEditor").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("at.obdev.LaunchBar.ActionEditor").pane2(getFrontApp()) end}
  },
  ["com.apple.ActivityMonitor"] = {
    ["CPU"] = {"cmd", "1", function() getAppEnv("com.apple.ActivityMonitor").clickActivityMonitorRadioButton(getFrontApp(), 1) end},
    ["Memory"] = {"cmd", "2", function() getAppEnv("com.apple.ActivityMonitor").clickActivityMonitorRadioButton(getFrontApp(), 2) end},
    ["Energy"] = {"cmd", "3", function() getAppEnv("com.apple.ActivityMonitor").clickActivityMonitorRadioButton(getFrontApp(), 3) end},
    ["Disk"] = {"cmd", "4", function() getAppEnv("com.apple.ActivityMonitor").clickActivityMonitorRadioButton(getFrontApp(), 4) end},
    ["Network"] = {"cmd", "5", function() getAppEnv("com.apple.ActivityMonitor").clickActivityMonitorRadioButton(getFrontApp(), 5) end},
    ["Quit Process"] = {"cmd", "delete", function() getFrontApp():selectMenuItem({"View", "Quit Process"}) end}
  },
  ["com.apple.AddressBook"] = {
    ["Contact Action 1"] = {'cmd', '1', function() getAppEnv("com.apple.AddressBook").performContactAction(getFrontApp(), 4) end},
    ["Contact Action 2"] = {'cmd', '2', function() getAppEnv("com.apple.AddressBook").performContactAction(getFrontApp(), 5) end},
    ["Contact Action 3"] = {'cmd', '3', function() getAppEnv("com.apple.AddressBook").performContactAction(getFrontApp(), 6) end},
    ["Contact Action 4"] = {'cmd', '4', function() getAppEnv("com.apple.AddressBook").performContactAction(getFrontApp(), 7) end}
  },
  ["com.kapeli.dashdoc"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.kapeli.dashdoc").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.kapeli.dashdoc").pane2(getFrontApp()) end},
    ["History"] = {"cmd", "y", function() getAppEnv("com.kapeli.dashdoc").clickOnHistoryMenuItem(getFrontApp()) end}
  },
  ["com.apple.Dictionary"] = {
    ["Pane 1"] = {'alt', '1', function() getAppEnv("com.apple.Dictionary").pane1(getFrontApp()) end},
    ["Pane 2"] = {'alt', '2', function() getAppEnv("com.apple.Dictionary").pane2(getFrontApp()) end},
    ["New Window"] = {'cmd', 'n', function() getAppEnv("com.apple.Dictionary").newWindow(getActiveModal()) end}
  },
  ["com.apple.finder"] = {
    ["Browse in LaunchBar"] = {"alt", "f", function() getAppEnv("com.apple.finder").browseInLaunchBar() end},
    ["Deselct All"] = {{"alt", "cmd"}, "a", function() getAppEnv("com.apple.finder").deselectAll(getFrontApp()) end},
    ["Move Focus to Files Area"] = {"alt", "2", function() getAppEnv("com.apple.finder").focusMainArea(getFrontApp()) end},
    ["New Window"] = {"cmd", "n", function() getAppEnv("com.apple.finder").newWindow(getActiveModal()) end},
    ["Open Folder in New Tab"] = {{"shift", "cmd"}, "down", function() getFrontApp():selectMenuItem({"File", "Open in New Tab"}) end},
    ["Open Package"] = {"alt", "o", function() getAppEnv("com.apple.finder").openPackage() end},
    ["Rename"] = {"cmd", "r", function() getAppEnv("com.apple.finder").clickOnRenameMenuItem(getFrontApp()) end},
    ["Right Size All Columns"] = {{"alt", "shift"}, "r", function() getAppEnv("com.apple.finder").rightSizeColumn(getFrontApp(), "all") end},
    ["Right Size This Column"] = {"alt", "r", function() getAppEnv("com.apple.finder").rightSizeColumn(getFrontApp(), "this") end},
    ["Show Next Tab"] = {{"alt", "cmd"}, "right", function()  getFrontApp():selectMenuItem({"Window", "Show Next Tab"}) end},
    ["Show Original"] = {{"shift", "cmd"}, "up", function() getFrontApp():selectMenuItem({"File", "Show Original"}) end},
    ["Show Previous Tab"] = {{"alt", "cmd"}, "left", function() getFrontApp():selectMenuItem({"Window", "Show Previous Tab"}) end},
    ["Undo Close Tab"] = {{"shift", "cmd"}, "t", function() getAppEnv("com.apple.finder").undoCloseTab() end},
    ["Move Focus to Files Area in the Search Window"] = {{}, "tab", function() getAppEnv("com.apple.finder").moveFocusToFilesAreaIfInSearchMode(getFrontApp(), getActiveModal()) end},
  },
  ["com.apple.FontBook"] = {
    ["Pane 1"] = {'alt', '1', function() getAppEnv("com.apple.FontBook").pane1(getFrontApp()) end},
    ["Pane 2"] = {'alt', '2', function() getAppEnv("com.apple.FontBook").pane2(getFrontApp()) end},
    ["Pane 3"] = {'alt', '3', function() getAppEnv("com.apple.FontBook").pane3(getFrontApp()) end},
  },
  ["com.google.Chrome"] = {
    ["Close Other Tabs"] = {{"alt", "cmd"}, "w", function() getAppEnv("com.google.Chrome").closeOtherTabs() end}
  },
  ["org.hammerspoon.Hammerspoon"] = {
    ["Clear Console"] = {'cmd', 'k', function() Console.clearConsole() end},
    ["Reload"] = {'cmd', 'r', function() hs.reload() end}
  },
  ["com.adobe.illustrator"] = {
    ["Next Tab"] = {"ctrl", "tab", function() EventTap.keyStroke({"cmd"}, "`") end},
    ["Previous Tab"] = {{"ctrl", "shift"}, "tab", function() EventTap.keyStroke({"cmd", "shift"}, "`") end},
  },
  ["com.adobe.InDesign"] = {
    ["Next Tab"] = {"ctrl", "tab", function() EventTap.keyStroke({"cmd"}, "`") end},
    ["Previous Tab"] = {{"shift", "ctrl"}, "tab", function() EventTap.keyStroke({"shift", "cmd"}, "`") end},
  },
  ["com.googlecode.iterm2"] = {
    ["Get Session Text"] = {"alt", "f", function() getAppEnv("com.googlecode.iterm2").getText() end}
  },
  ["com.apple.iWork.Keynote"] = {
    ["Pane 1"] = {'alt', '1', function() getAppEnv("com.apple.iWork.Keynote").pane1(getFrontApp()) end},
    ["Pane 2"] = {'alt', '2', function() getAppEnv("com.apple.iWork.Keynote").pane2(getFrontApp()) end}
  },
  ["com.apple.mail"] = {
    ["Get Message Text"] =  {"alt", "f", function() getAppEnv("com.apple.mail").getText() end},
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.mail").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.mail").pane2(getFrontApp()) end},
    ["Pane 3"] = {"alt", "3", function() getAppEnv("com.apple.mail").pane3(getFrontApp()) end},
    ["Show Links in Message"] = {"alt", "o", function() getAppEnv("com.apple.mail").getMessageLinks(getFrontApp()) end},
  },
  ["com.apple.iChat"] = {
    ["Show Links in Message"] = {"alt", "o", function() getAppEnv("com.apple.iChat").getLinks(getFrontApp()) end}
  },
  ["com.apple.Music"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.Music").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.Music").pane2(getFrontApp()) end},
    ["Show Filter Field"] = {"cmd", "l", function() getAppEnv("com.apple.Music").focusFilterField(getFrontApp()) end},
  },
  ["com.mrrsoftware.NameChanger"] = {
    ["Change Rename Type"] = {"cmd", "down", function() getAppEnv("com.mrrsoftware.NameChanger").changeRenameType() end}
  },
  ["com.apple.Notes"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.Notes").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.Notes").pane2(getFrontApp()) end},
    ["Pane 3"] = {"alt", "3", function() getAppEnv("com.apple.Notes").pane3(getFrontApp()) end},
    ["Search Notes with LaunchBar"] = {"alt", "f", function() getAppEnv("com.apple.Notes").searchNotesWithLaunchBar() end},
  },
  ["com.apple.iWork.Pages"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.iWork.Pages").pane1(getFrontApp()) end},
  },
  ["com.apple.Photos"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.Photos").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.Photos").pane2(getFrontApp()) end}
  },
  ["com.apple.Preview"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.Preview").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.Preview").pane2(getFrontApp()) end},
  },
  ["com.apple.reminders"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.reminders").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.reminders").pane2(getFrontApp()) end}
  },
  ["com.latenightsw.ScriptDebugger7"] = {
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.latenightsw.ScriptDebugger7").pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.latenightsw.ScriptDebugger7").pane2(getFrontApp()) end},
    ["Pane 3"] = {"alt", "3", function() getAppEnv("com.latenightsw.ScriptDebugger7").pane3(getFrontApp()) end}
  },
  ["com.adobe.xd"] = {
    ["Assets"] = {"cmd", "1", function() getFrontApp():selectMenuItem({"View", "Assets"}) end},
    ["Layers"] = {"cmd", "2", function() getFrontApp():selectMenuItem({"View", "Layers"}) end},
    ["Plugins"] = {"cmd", "3", function() getFrontApp():selectMenuItem({"View", "Plugins"}) end}
  },
  ["com.apple.Safari"] = {
    ["Move Tab Left"] = {"ctrl", ",", function() getAppEnv("com.apple.Safari").moveTab("left") end},
    ["Move Tab Right"] = {"ctrl", ".", function() getAppEnv("com.apple.Safari").moveTab("right") end},
    ["Pane 1"] = {"alt", "1", function() getAppEnv("com.apple.Safari").moveFocusToSafariMainArea(getFrontApp(), true) end},
    ["Pane 2"] = {"alt", "2", function() getAppEnv("com.apple.Safari").moveFocusToSafariMainArea(getFrontApp(), false) end},
    ["Get Page Text"] = {"alt", "f", function() getAppEnv("com.apple.Safari").getText() end},
    ["Right Size Bookmarks/History Column"] = {"alt", "r", function() getAppEnv("com.apple.Safari").rightSizeBookmarksOrHistoryColumn(getFrontApp()) end},
    ["New Window"] = {"cmd", "n", function() getFrontApp():selectMenuItem({"File", "New Window"}) end},
    ["Go to First Input Field"] = {"ctrl", "i", function() getAppEnv("com.apple.Safari").goToFirstInputField() end},
    ["Next Page"] = {"ctrl", "n", function() getAppEnv("com.apple.Safari").pageNavigation("next") end},
    ["Previous Page"] = {"ctrl", "p", function() getAppEnv("com.apple.Safari").pageNavigation("previous") end},
    ["Next Tab"] = {{"cmd", "alt"}, "right", function() getAppEnv("com.apple.Safari").switchTab(getFrontApp(), "Show Next Tab") end},
    ["Previous Tab"] = {{"cmd ", "alt"}, "left", function() getAppEnv("com.apple.Safari").switchTab(getFrontApp(), "Show Previous Tab") end},
    ["New Bookmarks Folder"] = {{"cmd", "shift"}, "n", function() getAppEnv("com.apple.Safari").newBookmarksFolder(getFrontApp()) end},
    ["Focus First Bookmark/History Item"] = {{}, "tab", function() getAppEnv("com.apple.Safari").firstSearchResult(getFrontApp(), getActiveModal()) end},
    ["Move Focus to Main Area After Opening Location"] = {{}, "return", function() getAppEnv("com.apple.Safari").moveFocusToMainAreaAfterOpeningLocation(getActiveModal(), {{}, "return"}, getFrontApp()) end}
  },
  ["desktop.WhatsApp"] = {
    ["Switch to ABC on Search"] = {"cmd", "f", function() getAppEnv("desktop.WhatsApp").switchToABCOnSearch(getFrontApp()) end}
  }
}

return obj
