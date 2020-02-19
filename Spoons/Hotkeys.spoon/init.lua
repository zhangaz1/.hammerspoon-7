local Hotkey = require("hs.hotkey")
local Window = require("hs.window")
local EventTap = require("hs.eventtap")
local Console = require("hs.console")

local hs = hs

local obj = {}

obj.__index = obj
obj.name = "Hotkeys"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.app = nil

local function getFrontApp()
  return spoon.AppWatcher.frontApp
end

local function getActiveModal()
  return spoon.AppWatcher.activeModal
end

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()

local hyper = {"cmd", "alt", "ctrl", "shift"}

local applicationHotkeysAndScripts = {
  ["com.agilebits.onepassword7"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.agilebits.onepassword7"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.agilebits.onepassword7"].pane2(getFrontApp()) end},    --
    ["Convert to Login"] = function() obj.app["com.agilebits.onepassword7"].convertToLogin() end,
    ["Sort By"] = function() obj.app["com.agilebits.onepassword7"].sortBy(getFrontApp()) end,
    ["Toggle Categories"] = function() obj.app["com.agilebits.onepassword7"].toggleCategories(getFrontApp(), "CATEGORIES") end,
    ["Toggle Tags"] = function() obj.app["com.agilebits.onepassword7"].toggleCategories(getFrontApp(), "TAGS") end,
    ["Toggle Watchtower"] = function() obj.app["com.agilebits.onepassword7"].toggleCategories(getFrontApp(), "WATCHTOWER") end,
  },
  ["at.obdev.LaunchBar.ActionEditor"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["at.obdev.LaunchBar.ActionEditor"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["at.obdev.LaunchBar.ActionEditor"].pane2(getFrontApp()) end}
  },
  ["com.apple.ActivityMonitor"] = {
    ["CPU"] = {"cmd", "1", function() obj.app["com.apple.ActivityMonitor"].clickActivityMonitorRadioButton(getFrontApp(), 1) end},
    ["Memory"] = {"cmd", "2", function() obj.app["com.apple.ActivityMonitor"].clickActivityMonitorRadioButton(getFrontApp(), 2) end},
    ["Energy"] = {"cmd", "3", function() obj.app["com.apple.ActivityMonitor"].clickActivityMonitorRadioButton(getFrontApp(), 3) end},
    ["Disk"] = {"cmd", "4", function() obj.app["com.apple.ActivityMonitor"].clickActivityMonitorRadioButton(getFrontApp(), 4) end},
    ["Network"] = {"cmd", "5", function() obj.app["com.apple.ActivityMonitor"].clickActivityMonitorRadioButton(getFrontApp(), 5) end},
    ["Quit Process"] = {"cmd", "delete", function() getFrontApp():selectMenuItem({"View", "Quit Process"}) end}
  },
  ["com.apple.AddressBook"] = {
    ["Contact Action 1"] = {'cmd', '1', function() obj.app["com.apple.AddressBook"].performContactAction(getFrontApp(), 4) end},
    ["Contact Action 2"] = {'cmd', '2', function() obj.app["com.apple.AddressBook"].performContactAction(getFrontApp(), 5) end},
    ["Contact Action 3"] = {'cmd', '3', function() obj.app["com.apple.AddressBook"].performContactAction(getFrontApp(), 6) end},
    ["Contact Action 4"] = {'cmd', '4', function() obj.app["com.apple.AddressBook"].performContactAction(getFrontApp(), 7) end}
  },
  ["com.kapeli.dashdoc"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.kapeli.dashdoc"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.kapeli.dashdoc"].pane2(getFrontApp()) end},
  },
  ["com.apple.Dictionary"] = {
    ["Pane 1"] = {'alt', '1', function() obj.app["com.apple.Dictionary"].pane1(getFrontApp()) end},
    ["Pane 2"] = {'alt', '2', function() obj.app["com.apple.Dictionary"].pane2(getFrontApp()) end}
  },
  ["com.apple.finder"] = {
    ["Browse Folder Contents"] = {{"alt", "cmd"}, "down", function() obj.app["com.apple.finder"].browseFolderContents() end},
    ["Browse in LaunchBar"] = {"alt", "f", function() obj.app["com.apple.finder"].browseInLaunchBar() end},
    ["Deselct All"] = {{"alt", "cmd"}, "a", function() obj.app["com.apple.finder"].deselectAll() end},
    ["Move Focus to Files Area"] = {"alt", "2", function() obj.app["com.apple.finder"].focusMainArea(getFrontApp()) end},
    ["New Window"] = {"cmd", "n", function() EventTap.keyStroke({"cmd", "alt"}, "n") end},
    ["Open Folder in New Tab"] = {{"shift", "cmd"}, "down", function() getFrontApp():selectMenuItem({"File", "Open in New Tab"}) end},
    ["Open Package"] = {"alt", "o", function() obj.app["com.apple.finder"].openPackage() end},
    ["Rename"] = {"cmd", "r", function() obj.app["com.apple.finder"].clickOnRenameMenuItem(getFrontApp()) end},
    ["Right Size All Columns"] = {{"alt", "shift"}, "r", function() obj.app["com.apple.finder"].rightSizeColumn(getFrontApp(), "all") end},
    ["Right Size This Column"] = {"alt", "r", function() obj.app["com.apple.finder"].rightSizeColumn(getFrontApp(), "this") end},
    ["Show Next Tab"] = {{"alt", "cmd"}, "right", function()  getFrontApp():selectMenuItem({"Window", "Show Next Tab"}) end},
    ["Show Original"] = {{"shift", "cmd"}, "up", function() getFrontApp():selectMenuItem({"File", "Show Original"}) end},
    ["Show Previous Tab"] = {{"alt", "cmd"}, "left", function() getFrontApp():selectMenuItem({"Window", "Show Previous Tab"}) end},
    ["Undo Close Tab"] = {{"shift", "cmd"}, "t", function() obj.app["com.apple.finder"].undoCloseTab() end},
    ["Move Focus to Files Area in the Search Window"] = {{}, "tab", function() obj.app["com.apple.finder"].moveFocusToFilesAreaIfInSearchMode(getFrontApp(), getActiveModal()) end},
    --
    -- previous folders
    -- next folders
    ["Deselect All"] = function() obj.app["com.apple.finder"].deselectAll() end,
    ["Dropbox Smart Sync: Local"] = function() obj.app["com.apple.finder"].dropboxSmartSyncToggle("Local") end,
    ["Dropbox Smart Sync: Online Only"] = function() obj.app["com.apple.finder"].dropboxSmartSyncToggle("Online Only") end,
    ["Duplicate Tab"] = function() obj.app["com.apple.finder"].duplicateTab() end,
    ["Go Back"] = function() obj.app["com.apple.finder"].clickHistoryToolbarItem(getFrontApp(), "back") end,
    ["Go Forward"] = function() obj.app["com.apple.finder"].clickHistoryToolbarItem(getFrontApp(), "forward") end,
    ["Invert Selection"] = function() obj.app["com.apple.finder"].invertSelection() end,
    ["Next Search Scope"] = function() obj.app["com.apple.finder"].nextSearchScope() end,
    ["Toggle Columns"] = function() obj.app["com.apple.finder"].toggleColumns() end,
    ["Toggle Sort Direction"] = function() obj.app["com.apple.finder"].toggleSortingDirection() end,
    ["Traverse Up"] = function() obj.app["com.apple.finder"].traverseUp() end,
  },
  ["com.apple.FontBook"] = {
    ["Pane 1"] = {'alt', '1', function() obj.app["com.apple.FontBook"].pane1(getFrontApp()) end},
    ["Pane 2"] = {'alt', '2', function() obj.app["com.apple.FontBook"].pane2(getFrontApp()) end},
    ["Pane 3"] = {'alt', '3', function() obj.app["com.apple.FontBook"].pane3(getFrontApp()) end},
  },
  ["com.google.Chrome"] = {
    ["Close Other Tabs"] = {{"alt", "cmd"}, "w", function() obj.app["com.google.Chrome"].closeOtherTabs() end}
  },
  ["org.hammerspoon.Hammerspoon"] = {
    ["Clear Console"] = {'cmd', 'k', function() Console.clearConsole() end},
    ["Reload"] = {'cmd', 'r', function() hs.reload() end}
  },
  ["com.adobe.illustrator"] = {
    ["Next Tab"] = {"ctrl", "tab", function() EventTap.keyStroke({"cmd"}, "`") end},
    ["Previous Tab"] = {{"ctrl", "shift"}, "tab", function() EventTap.keyStroke({"cmd", "shift"}, "`") end},
    --
    ["Export Artboards as PDFs to Desktop"] = function() obj.app["com.adobe.illustrator"].exportAs("pdf") end,
    ["Export Artboards as PNGs to Desktop"] = function() obj.app["com.adobe.illustrator"].exportAs("png") end,
    ["Export Artboards as SVGs to Desktop"] = function() obj.app["com.adobe.illustrator"].exportAs("svg") end,
  },
  ["com.adobe.InDesign"] = {
    ["Next Tab"] = {"ctrl", "tab", function() EventTap.keyStroke({"cmd"}, "`") end},
    ["Previous Tab"] = {{"shift", "ctrl"}, "tab", function() EventTap.keyStroke({"shift", "cmd"}, "`") end},
    --
    ["Export as as PNG to Desktop"] = function() obj.app["com.adobe.InDesign"].exportAsPNG() end,
    ["Export as High Quality PDF to Desktop"] = function() obj.app["com.adobe.InDesign"].exportAsPDF() end,
  },
  ["com.googlecode.iterm2"] = {
    ["Get Session Text"] = {"alt", "f", function() obj.app["com.googlecode.iterm2"].getText() end}
  },
  ["com.apple.iWork.Keynote"] = {
    ["Pane 1"] = {'alt', '1', function() obj.app["com.apple.iWork.Keynote"].pane1(getFrontApp()) end},
    ["Pane 2"] = {'alt', '2', function() obj.app["com.apple.iWork.Keynote"].pane2(getFrontApp()) end}
  },
  ["com.apple.mail"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.mail"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.mail"].pane2(getFrontApp()) end},
    ["Pane 3"] = {"alt", "3", function() obj.app["com.apple.mail"].pane3(getFrontApp()) end},
    ["Show Links in Message"] = {"alt", "o", function() obj.app["com.apple.mail"].getMessageLinks(getFrontApp()) end},
    ["Copy Sender's Addresss"] = function() obj.app["com.apple.mail"].copySenderAddres() end,
  },
  ["com.apple.iChat"] = {
    ["Show Links in Message"] = {"alt", "o", function() obj.app["com.apple.iChat"].getLinks() end}
  },
  ["com.apple.Music"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.Music"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.Music"].pane2(getFrontApp()) end}
  },
  ["com.mrrsoftware.NameChanger"] = {
    ["Change Rename Type"] = {"cmd", "down", function() obj.app["com.mrrsoftware.NameChanger"].changeRenameType() end}
  },
  ["com.apple.Notes"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.Notes"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.Notes"].pane2(getFrontApp()) end},
    ["Pane 3"] = {"alt", "3", function() obj.app["com.apple.Notes"].pane3(getFrontApp()) end},
    ["Left to Right Writing Direction"] = function() obj.app["com.apple.Notes"].writingDirection("Left to Right") end,
    ["Right to Left Writing Direction"] = function() obj.app["com.apple.Notes"].writingDirection("Right to Left") end
  },
  ["com.apple.iWork.Pages"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.iWork.Pages"].pane1(getFrontApp()) end},
    ["Font Family"] = function() obj.app["com.apple.iWork.Pages"].fontFamily() end,
    ["Paragraph Style"] = function() obj.app["com.apple.iWork.Pages"].paragraphStyle() end,
  },
  ["com.apple.Photos"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.Photos"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.Photos"].pane2(getFrontApp()) end}
  },
  ["com.adobe.Photoshop"] = {
    ["Auto Adjustments"] = function() obj.app["com.adobe.Photoshop"].autoAdjustments(getFrontApp()) end
  },
  ["com.apple.Preview"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.Preview"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.Preview"].pane2(getFrontApp()) end},
    ["Go to First Page"] = function() obj.app["com.apple.Preview"].goToFirstPage() end,
    ["Go to Last Page"] = function() obj.app["com.apple.Preview"].goToLastPage() end
  },
  ["com.apple.reminders"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.reminders"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.reminders"].pane2(getFrontApp()) end}
  },
  ["com.latenightsw.ScriptDebugger7"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.latenightsw.ScriptDebugger7"].pane1(getFrontApp()) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.latenightsw.ScriptDebugger7"].pane2(getFrontApp()) end},
    ["Pane 3"] = {"alt", "3", function() obj.app["com.latenightsw.ScriptDebugger7"].pane3(getFrontApp()) end}
  },
  ["com.apple.systempreferences"] = {
    ["Authorize Pane"] = function() obj.app["com.apple.systempreferences"].authorizePane() end,
    ["Allow/Enable..."] = function() obj.app["com.apple.systempreferences"].allowAnyway() end,
  },
  ["desktop.WhatsApp"] = {
    ["Insert GIF"] = function() obj.app["desktop.WhatsApp"].insertGif() end,
    ["Attach File"] = function() obj.app["desktop.WhatsApp"].whatsAppMouseScripts("AttachFile") end,
    ["Use Here"] = function() obj.app["desktop.WhatsApp"].whatsAppMouseScripts("Use Here") end
  },
  ["com.adobe.xd"] = {
    ["Assets"] = {"cmd", "1", function() getFrontApp():selectMenuItem({"View", "Assets"}) end},
    ["Layers"] = {"cmd", "2", function() getFrontApp():selectMenuItem({"View", "Layers"}) end},
    ["Plugins"] = {"cmd", "3", function() getFrontApp():selectMenuItem({"View", "Plugins"}) end}
  },
  ["com.apple.Safari"] = {
    ["Pane 1"] = {"alt", "1", function() obj.app["com.apple.Safari"].moveFocusToSafariMainArea(getFrontApp(), true) end},
    ["Pane 2"] = {"alt", "2", function() obj.app["com.apple.Safari"].moveFocusToSafariMainArea(getFrontApp(), false) end},
    ["Get Page Text"] = {"alt", "f", function() obj.app["com.apple.Safari"].getText() end},
    ["Right Size Bookmarks/History Column"] = {"alt", "r", function() obj.app["com.apple.Safari"].rightSizeBookmarksOrHistoryColumn(getFrontApp()) end},
    ["New Window"] = {"cmd", "n", function() getFrontApp():selectMenuItem({"File", "New Window"}) end},
    ["Go to First Input Field"] = {"ctrl", "i", function() obj.app["com.apple.Safari"].goToFirstInputField() end},
    ["Next Page"] = {"ctrl", "n", function() obj.app["com.apple.Safari"].pageNavigation("next") end},
    ["Previous Page"] = {"ctrl", "p", function() obj.app["com.apple.Safari"].pageNavigation("previous") end},
    ["Next Tab"] = {{"cmd", "alt"}, "right", function() obj.app["com.apple.Safari"].switchTab(getFrontApp(), "Show Next Tab") end},
    ["Previous Tab"] = {{"cmd ", "alt"}, "left", function() obj.app["com.apple.Safari"].switchTab(getFrontApp(), "Show Previous Tab") end},
    ["New Bookmarks Folder"] = {{"cmd", "shift"}, "n", function() obj.app["com.apple.Safari"].newBookmarksFolder(getFrontApp()) end},
    ["Focus First Bookmark/History Item"] = {{}, "tab", function() obj.app["com.apple.Safari"].firstSearchResult(getFrontApp(), getActiveModal()) end},
    --
    -- previous websites
    -- next websites
    ["Close Tabs to the Left"] = function() obj.app["com.apple.Safari"].closeTabsToDirection("left") end,
    ["Close Tabs to the Right"] = function() obj.app["com.apple.Safari"].closeTabsToDirection("right") end,
    ["Duplicate Tab"] = function() obj.app["com.apple.Safari"].duplicateTab() end,
    ["New Invoice for Current iCount Customer"] = function() obj.app["com.apple.Safari"].newInvoiceForCurrentIcountCustomer() end,
    ["Open This Tab in Chrome"] = function() obj.app["com.apple.Safari"].openThisTabInChrome() end,
    ["Save Page as PDF"] = function() obj.app["com.apple.Safari"].savePageAsPDF() end,
    ["Translate"] = function() obj.app["com.apple.Safari"].clickOnTranslateMeMenuButton() end,
    ["Open as Private Tab"] = function() obj.app["com.apple.Safari"].openAsPrivateTab() end,
  }
}

local function globalHotkeys()
  Hotkey.bind("alt", "q", function() obj.launch() end)

  Hotkey.bind("alt", "e", function() spoon.GlobalScripts.showHelpMenu() end)
  Hotkey.bind({"cmd", "shift"}, "1", function() spoon.GlobalScripts.moveFocusToMenuBar() end)
  Hotkey.bind(hyper, "o", function() spoon.GlobalScripts.rightClick() end)

  Hotkey.bind(hyper, "1", function() spoon.GlobalScripts.notificationCenterClickButton(1) end)
  Hotkey.bind(hyper, "2", function() spoon.GlobalScripts.notificationCenterClickButton(2) end)
  Hotkey.bind(hyper, "3", function() spoon.GlobalScripts.notificationCenterClickButton(3) end)
  Hotkey.bind(hyper, "n", function() spoon.GlobalScripts.notificationCenterToggle() end)

  Hotkey.bind(hyper, "c", function() Window.focusedWindow():centerOnScreen() end)
  Hotkey.bind(hyper, "down", function() spoon.WindowManager.pushToCell("Down") end)
  Hotkey.bind(hyper, "l", function() spoon.GlobalScripts.lookUpInDictionary() end)
  Hotkey.bind(hyper, "left", function() spoon.WindowManager.pushToCell("Left") end)
  Hotkey.bind(hyper, "return", function() spoon.WindowManager.maximize() end)
  Hotkey.bind(hyper, "right", function() spoon.WindowManager.pushToCell("Right") end)
  Hotkey.bind(hyper, "up", function() spoon.WindowManager.pushToCell("Up") end)
  Hotkey.bind(hyper, "w", function() spoon.WindowManagerModal:start() end)
end

obj.modals = {}
obj.scripts = {}

function obj:init()
  for bundleID, appTable in pairs(applicationHotkeysAndScripts) do
    obj.modals[bundleID] = Hotkey.modal.new()
    obj.scripts[bundleID] = {}
    for commandName, command in pairs(appTable) do
      if type(command) == "table" then
        obj.modals[bundleID]:bind(table.unpack(command))
      else
        obj.scripts[bundleID][commandName] = command
      end
    end
  end
end

function obj:start()
  obj.app = spoon.ApplicationScripts.appEnvs
  globalHotkeys()
end

local application = require("hs.application")
local GlobalChooser = require("rb.fuzzychooser")
local Image = require("hs.image")

local function chooserCallback(choice)
  obj.scripts[choice.bundleID][choice.text]()
end

function obj:launch()
  local frontApp = application:frontmostApplication()
  local frontAppID = frontApp:bundleID()
  local choices = {}
  for bundleID, services in pairs(obj.scripts) do
    if bundleID == frontAppID then
      for serviceTitle, _ in pairs(services) do
        table.insert(
          choices,
          {
            text = serviceTitle,
            subText = "Application Script",
            bundleID = bundleID,
            image = Image.imageFromAppBundle(frontAppID)
          }
        )
      end
    end
  end
  GlobalChooser:start(chooserCallback, choices, {"text"})
end

return obj




-- return obj
