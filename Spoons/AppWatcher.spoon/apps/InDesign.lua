local hotkey = require("hs.hotkey")
local eventtap = require("hs.eventtap")
local OSAScript = require("hs.osascript")

local obj = {}

obj.id = "com.adobe.InDesign"
obj.modal = hotkey.modal.new()

local function exportAs()
  OSAScript.applescript([[
    set thePath to POSIX path of (path to desktop folder)
    tell application id "com.adobe.InDesign"
      set theName to name of active document
      set thePreset to PDF export preset 1 whose name is "[High Quality Print]"
      asynchronous export file active document format PDF type to thePath & theName & ".pdf" using thePreset without showing options and force save
    end tell
  ]])
end

obj.modal:bind(
  {"ctrl"},
  "tab",
  function()
    eventtap.keyStroke({"cmd"}, "`")
  end
)
obj.modal:bind(
  {"shift", "ctrl"},
  "tab",
  function()
    eventtap.keyStroke({"shift", "cmd"}, "`")
  end
)

obj.appScripts = {
  {
    title = "Export as as High Quality PDF to Desktop",
    func = exportAs
  }
}

return obj
