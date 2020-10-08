local FS = require("hs.fs")
local window = require("hs.window")
local ipc = require("hs.ipc")
local application = require("hs.application")
local hs = hs

----------------------------------
-- HAMMERSPOON SETTINGS, VARIABLES
----------------------------------
require("hs.keycodes").log.setLogLevel("error")
application.enableSpotlightForNameSearches(true)
hs.allowAppleScript(true)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.hotkey.setLogLevel("error")
hs.logger.defaultLogLevel = "error"
hs.menuIcon(false)
ipc.cliUninstall()
ipc.cliInstall()
window.animationDuration = 0

---------
-- SPOONS
---------
local hyper = {"shift", "cmd", "alt", "ctrl"}

-- load
local iterFn, dirObj = FS.dir("Spoons/")
if iterFn then
  for file in iterFn, dirObj do
    if string.sub(file, -5) == "spoon" then
      local spoonName = string.sub(file, 1, -7)
      hs.loadSpoon(spoonName)
    end
  end
end

-- start - ORDER MATTERS!
spoon.AppQuitter:start({
  ["com.kapeli.dashdoc"] = {quit = 6, hide = 1},
  ["com.google.Chrome"] = {quit = 4, hide = 1},
  ["at.obdev.LaunchBar.ActionEditor"] = {quit = 0.5, hide = 0.5},
  ["com.apple.Preview"] = {quit = 1, hide = 0.5},
  ["com.toggl.toggldesktop.TogglDesktop"] = {quit = 8, hide = 0.5},
  ["com.latenightsw.ScriptDebugger7"] = {quit = 1, hide = 0.5},
  ["com.apple.iphonesimulator"] = {quit = 1, hide = 0.5},
  ["fr.handbrake.HandBrake"] = {quit = 10, hide = 0.5},
  "app.soulver.mac",
  "com.adobe.illustrator",
  "com.adobe.InDesign",
  "com.adobe.Photoshop",
  "com.apple.ActivityMonitor",
  "com.apple.AddressBook",
  "com.apple.airport.airportutility",
  "com.apple.AppStore",
  "com.apple.audio.AudioMIDISetup",
  "com.apple.Automator",
  "com.apple.backup.launcher",
  "com.apple.BluetoothFileExchange",
  "com.apple.bootcampassistant",
  "com.apple.calculator",
  "com.apple.Chess",
  "com.apple.ColorSyncUtility",
  "com.apple.Console",
  "com.apple.Dictionary",
  "com.apple.DigitalColorMeter",
  "com.apple.DiskUtility",
  "com.apple.dt.Xcode",
  "com.apple.FaceTime",
  "com.apple.findmy",
  "com.apple.FontBook",
  "com.apple.grapher",
  "com.apple.Home",
  "com.apple.iBooksX",
  "com.apple.iCal",
  "com.apple.iChat",
  "com.apple.Image_Capture",
  "com.apple.iWork.Keynote",
  "com.apple.iWork.Numbers",
  "com.apple.iWork.Pages",
  "com.apple.keychainaccess",
  "com.apple.Maps",
  "com.apple.MigrateAssistant",
  "com.apple.Music",
  "com.apple.Notes",
  "com.apple.PhotoBooth",
  "com.apple.Photos",
  "com.apple.podcasts",
  "com.apple.QuickTimePlayerX",
  "com.apple.reminders",
  "com.apple.screenshot.launcher",
  "com.apple.ScriptEditor2",
  "com.apple.SFSymbols",
  "com.apple.Stickies",
  "com.apple.stocks",
  "com.apple.systempreferences",
  "com.apple.SystemProfiler",
  "com.apple.Terminal",
  "com.apple.TextEdit",
  "com.apple.TV",
  "com.apple.VoiceMemos",
  "com.apple.VoiceOverUtility",
  "com.bjango.istatmenus",
  "com.colliderli.iina",
  "com.coteditor.CotEditor",
  "com.cryptic-apps.hopper-web-4",
  "com.figma.Desktop",
  "com.giorgiocalderolla.Wipr-Mac",
  "com.groosoft.CommentHere",
  "com.macitbetter.betterzip",
  "com.microsoft.VSCode",
  "com.pfiddlesoft.uibrowser",
  "com.postmanlabs.mac",
  "com.samuelmeuli.Glance",
  "com.savantav.truecontrol",
  "com.ScooterSoftware.BeyondCompare",
  "com.sidetree.Translate",
  "com.wolfrosch.Gapplin",
  "de.just-creative.inddPreview",
  "developer.apple.wwdc-Release",
  "io.dictionaries.Dictionaries",
  "me.spaceinbox.Select-Like-A-Boss-For-Safari",
  "net.bluem.pashua",
  "net.freemacsoft.AppCleaner",
  "net.sourceforge.sqlitebrowser",
  "net.televator.Vimari",
  "us.zoom.xos",
})

spoon._Finder:bindModalHotkeys({
  browseInLaunchBar = {"alt", "f"},
  focusMainArea = {"alt", "2"},
  newWindow = {"cmd", "n"},
  undoCloseTab = {{"shift", "cmd"}, "t"},
  moveFocusToFilesAreaIfInSearchMode = {{}, "tab"},
  showOriginalFile = {{"shift", "cmd"}, "up"},
  openInNewTab = {{"shift", "cmd"}, "down"},
  openPackage = {"alt", "o"},
  rightSizeColumnAllColumns = {{"alt", "shift"}, "r"},
  rightSizeColumnThisColumn = {"alt", "r"}
})
spoon._Safari:bindModalHotkeys({
  moveTabLeft = {"ctrl", ","},
  moveTabRight = {"ctrl", "."},
  newWindow = {"cmd", "n"},
  goToFirstInputField = {"ctrl", "i"},
  goToNextPage = {"ctrl", "n"},
  goToPreviousPage = {"ctrl", "p"},
  moveFocusToMainAreaAndChangeToABCAfterOpeningLocation = {{}, "return"},
  changeToABCAfterFocusingAddressBar = {"cmd", "l"},
  focusSidebar = {"alt", "1"},
  focusMainArea = {"alt", "2"},
  newBookmarksFolder = {{"cmd", "shift"}, "n"},
  rightSizeBookmarksOrHistoryColumn = {"alt", "r"},
  firstSearchResult = {{}, "tab"}
})

spoon.AppWatcher:start()
spoon.AppearanceWatcher:start()
spoon.ConfigWatcher:start()
spoon.DownloadsWatcher:start()
spoon.WifiWatcher:start()
spoon.KeyboardLayoutManager:bindHotKeys({toggleInputSource = {{}, 10}})
spoon.Globals:bindHotKeys({
  focusMenuBar = {{"cmd", "shift"}, "1"},
  rightClick = {hyper, "o"},
  focusDock = {{"cmd", "alt"}, "d"}
})
spoon.WindowManager:bindHotKeys({
  pushLeft = {hyper, "left"},
  pushRight = {hyper, "right"},
  pushUp = {hyper, "up"},
  pushDown = {hyper, "down"},
  maximize = {hyper, "return"},
  center = {hyper, "c"}
})
spoon.NotificationCenter:bindHotKeys({
  firstButton = {hyper, "1"},
  secondButton = {hyper, "2"},
  thirdButton = {hyper, "3"},
  toggle = {hyper, "n"}
})
spoon.StatusBar:start()

-- "ActionEditor"
-- pane1
-- pane2
-- "Contacts"
-- contactAction1
-- contactAction2
-- contactAction3
-- contactAction4
-- "Dictionary"
-- pane1
-- pane2
-- newWindow
-- "FontBook"
-- pane1
-- pane2
-- pane3
-- "Chrome"
-- closeOtherTabs
-- "Keynote"
-- pane1
-- pane2
-- "Music"
-- pane1
-- pane2
-- focusFilterField
-- "Photos"
-- pane1
-- pane2
-- "Preview"
-- pane1
-- pane2
-- "Reminders"
-- pane1
-- pane2
-- "Script Debugger"
-- pane1
-- pane2
-- "WhatsApp"
--  switchToABCOnSearch
