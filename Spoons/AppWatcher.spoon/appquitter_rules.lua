local minute = 60
local hour = 60 * minute
local DEFAULT_QUIT_INTERVAL = 4 * hour
local DEFAULT_HIDE_INTERVAL = 10 * minute

local RULES = {
  ["com.kapeli.dashdoc"] = {
    quit = 6 * hour,
    hide = 1 * hour
  },
  ["com.google.Chrome"] = {
    quit = 4 * hour,
    hide = 1 * hour
  },
  ["at.obdev.LaunchBar.ActionEditor"] = {
    quit = 30 * minute,
    hide = 10 * minute
  },
  ["com.apple.Preview"] = {
    quit = 30 * minute,
    hide = 10 * minute
  },
  ["com.toggl.toggldesktop.TogglDesktop"] = {
    quit = 8 * hour,
    hide = 10 * minute
  },
  ["com.latenightsw.ScriptDebugger7"] = {
    quit = hour,
    hide = 10 * minute
  },
  ["com.apple.iphonesimulator"] = {
    quit = hour,
    hide = 10 * minute
  }
}

local APPLY_DEFAULTS = {
  "app.soulver.mac",
  "com.adobe.acc.AdobeCreativeCloud",
  "com.adobe.AfterEffects",
  "com.adobe.ame.application.14",
  "com.adobe.illustrator",
  "com.adobe.InDesign",
  "com.adobe.Photoshop",
  "com.apple.ActivityMonitor",
  "com.apple.AddressBook",
  "com.apple.AppStore",
  "com.apple.Automator",
  "com.apple.calculator",
  "com.apple.Console",
  "com.apple.Dictionary",
  "com.apple.DiskUtility",
  "com.apple.dt.Xcode",
  "com.apple.FaceTime",
  "com.apple.findmy",
  "com.apple.FontBook",
  "com.apple.Home",
  "com.apple.iBooksX",
  "com.apple.iCal",
  "com.apple.iChat",
  "com.apple.iMovieApp",
  "com.apple.iWork.Keynote",
  "com.apple.iWork.Numbers",
  "com.apple.iWork.Pages",
  "com.apple.Maps",
  "com.apple.Music",
  "com.apple.Notes",
  "com.apple.PhotoBooth",
  "com.apple.Photos",
  "com.apple.podcasts",
  "com.apple.QuickTimePlayerX",
  "com.apple.reminders",
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
  "com.colliderli.iina",
  "com.coteditor.CotEditor",
  "com.cryptic-apps.hopper-web-4",
  "com.facebook.archon",
  "com.figma.Desktop",
  "com.google.Chrome",
  "com.helloresolven.GIF-Brewery-3",
  "com.macitbetter.betterzip",
  "com.microsoft.VSCode",
  "com.mrrsoftware.NameChanger",
  "com.pfiddlesoft.uibrowser",
  "com.savantav.truecontrol",
  "com.ScooterSoftware.BeyondCompare",
  "com.sindresorhus.Gifski",
  "com.teamviewer.TeamViewer",
  "com.unity3d.unityhub",
  "com.wolfrosch.Gapplin",
  "fr.handbrake.HandBrake",
  "jp.tmkk.XLD",
  "net.freemacsoft.AppCleaner",
  "net.pornel.ImageOptim",
  "net.sourceforge.sqlitebrowser",
  "us.zoom.xos"
}

for _, v in ipairs(APPLY_DEFAULTS) do
  RULES[v] = {
    quit = DEFAULT_QUIT_INTERVAL,
    hide = DEFAULT_HIDE_INTERVAL
  }
end

return RULES
