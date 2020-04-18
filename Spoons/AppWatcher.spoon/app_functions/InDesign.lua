local applescript = require("hs.osascript").applescript

local obj = {}

obj.id = "com.adobe.InDesign"

local function export(fmt)
  local script = string.format([[
    set fmt to "%s"
    set thePath to POSIX path of (path to desktop folder)
    tell application id "com.adobe.InDesign"
      set theName to name of active document
      set thePath to thePath & theName & "." & fmt
      if fmt is "pdf" then
        set thePreset to PDF export preset 1 whose name is "[High Quality Print]"
        set theTask to asynchronous export file active document format PDF type to thePath using thePreset without showing options and force save
        wait for task (theTask)
      else if fmt is "png" then
        export active document format PNG format to thePath without showing options and force save
      end if
    end tell
    tell application "Finder"
      reveal POSIX file thePath
      activate
    end tell
  ]], fmt)
  applescript(script)
end

function obj.exportAsPDF()
  export("pdf")
end

function obj.exportAsPNG()
  export("png")
end

return obj
