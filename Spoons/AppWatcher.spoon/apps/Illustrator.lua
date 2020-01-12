local OSAScript = require("hs.osascript")
local hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")

local obj = {}
obj.id = "com.adobe.illustrator"
obj.modal = hotkey.modal.new()

local function exportAs(fmt)
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

obj.modal:bind(
  {"ctrl"},
  "tab",
  function()
    eventtap.keyStroke({"cmd"}, "`")
  end
)
obj.modal:bind(
  {"ctrl", "shift"},
  "tab",
  function()
    eventtap.keyStroke({"cmd", "shift"}, "`")
  end
)

obj.appScripts = {
	{
		title = "Export Artboards as PDFs to Desktop",
		func = function() exportAs("pdf") end
  },
  {
		title = "Export Artboards as PNGs to Desktop",
		func = function() exportAs("png") end
  },
  {
		title = "Export Artboards as SVGs to Desktop",
		func = function() exportAs("svg") end
	}
}

return obj
