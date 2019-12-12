local Window = require("hs.window")
local Chooser = require("util.FuzzyChooser")
local Image = require("hs.image")

local obj = {}

obj.chooser = nil

local function fn(choice)
  Window.get(choice.id):focus()
end

-- local filter = Window.filter.new(nil)
function obj.start()
  local wins = {}
  local visibleWindows = Window.visibleWindows()
  for _, win in ipairs(visibleWindows) do
    local add = true
    local title = win:title()
    local app = win:application()
    local appName = app:name()
    local bundle = app:bundleID()
    local id = win:id()
    if title == "" then
      title = nil
      if appName == "Finder" or appName == "Safari" then
        add = false
      end
    end
    if add then
      table.insert(
        wins,
        {
          text = appName,
          subText = title,
          id = id,
          image = Image.imageFromAppBundle(bundle)
        }
      )
    end
  end
  obj.chooser = Chooser.start(fn, wins, {"text", "subText"})
end

obj.start()

return obj
