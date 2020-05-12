local geometry = require("hs.geometry")
local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local timer = require("hs.timer")
local Keycodes = require("hs.keycodes")

local obj = {}

obj.id = "desktop.WhatsApp"

function obj.switchToABCOnSearch(appObj)
  Keycodes.setLayout("ABC")
  appObj:selectMenuItem({"Edit", "Search"})
end

function obj.whatsAppMouseScripts(appObj, requestedAction)
  local x
  local y
  local frame = appObj:focusedWindow():frame()
  if requestedAction == "AttachFile" then
    x = (frame.x + frame.w - 85)
    y = (frame.y + 30)
  else
    x = (frame.center.x + 80)
    y = (frame.center.y + 30)
  end
  local p = geometry.point({x, y})
  return eventtap.leftClick(p)
end

function obj.insertGif()
  keycodes.setLayout("ABC") -- HEBREW RELATED
  timer.doAfter(
    0.4,
    function()
      eventtap.keyStroke({"shift"}, "tab")
      timer.doAfter(
        0.4,
        function()
          eventtap.keyStroke({}, "return")
          timer.doAfter(
            0.4,
            function()
              eventtap.keyStroke({}, "tab")
            end
          )
        end
      )
    end
  )
end

return obj