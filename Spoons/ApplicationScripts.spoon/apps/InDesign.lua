local OSAScript = require("hs.osascript")

local obj = {}

obj.id = "com.adobe.InDesign"

function obj.exportAsPDF()
  OSAScript.applescript([[
    set thePath to POSIX path of (path to desktop folder)
    tell application id "com.adobe.InDesign"
      set theName to name of active document
      set thePreset to PDF export preset 1 whose name is "[High Quality Print]"
      asynchronous export file active document format PDF type to thePath & theName & ".pdf" using thePreset without showing options and force save
    end tell
  ]])
end

function obj.exportAsPNG()
  OSAScript.applescript([[
    set thePath to POSIX path of (path to desktop folder)
    tell application id "com.adobe.InDesign"
      set theName to name of active document
      export active document format PNG format to thePath & theName & ".png" without showing options and force save
    end tell
  ]])
end

return obj
