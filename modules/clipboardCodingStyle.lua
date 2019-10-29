local styledtext = require("hs.styledtext")
local drawing = require("hs.drawing")
local pasteboard = require("hs.pasteboard")
local eventtap = require("hs.eventtap")

local m = {}

m.setStyle = function(theText)
    local styledText =
        styledtext.new(
        theText,
        {
            font = "Menlo",
            backgroundColor = drawing.color.colorsFor("Crayons")["Mercury"],
            color = drawing.color.colorsFor("Apple")["Black"]
        }
    )
    if pasteboard.writeObjects(styledText) then
        eventtap.keyStroke({"cmd"}, "v")
    end
end

return m
