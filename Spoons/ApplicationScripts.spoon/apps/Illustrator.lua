local OSAScript = require("hs.osascript")

local obj = {}

obj.id = "com.adobe.illustrator"

function obj.exportAs(fmt)
  if fmt == "pdf" then
    fmt = "se_pdf"
  elseif fmt == "png" then
    fmt = "se_png24"
  elseif fmt == "svg" then
    fmt = "se_svg"
  end
  OSAScript.applescript(string.format([[
    set desktopFolder to POSIX path of (path to desktop folder)
    tell application "Adobe Illustrator"
      tell document 1
        set _name to its name
        exportforscreens to folder desktopFolder as %s filenameprefix (_name & "_")
      end tell
    end tell
  ]], fmt))
end

return obj
