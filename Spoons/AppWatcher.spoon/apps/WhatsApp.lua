local hotkey = require("hs.hotkey")
local geometry = require("hs.geometry")
local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local timer = require("hs.timer")

local mod = {}

mod.id = "desktop.WhatsApp"
mod.thisApp = nil
mod.modal = hotkey.modal.new()

switchToEnglishOnSearch =
  eventtap.new(
  {eventtap.event.types.keyUp},
  function(event)
    local f = 3
    if (event:getKeyCode() == f) and event:getFlags():containExactly({"cmd"}) then
      -- print(keyName)
      keycodes.setLayout("ABC")
    end
    return
  end
)

local function whatsAppMouseScripts(requestedAction)
  local x
  local y
  local frame = mod.thisApp:focusedWindow():frame()
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

local function insertGif()
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

-- BEGIN HEBREW RELATED
mod.searchAction = switchToEnglishOnSearch
-- END HEBREW RELATED

mod.appScripts = {
  {title = "Insert GIF", func = function()
      insertGif()
    end},
  {title = "Attach File", func = function()
      whatsAppMouseScripts("AttachFile")
    end},
  {title = "Use Here", func = function()
      whatsAppMouseScripts("Use Here")
    end}
}

mod.listeners = {
  mod.searchAction
}

return mod