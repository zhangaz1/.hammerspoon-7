local hs = hs
local Fnutils = require("hs.fnutils")
local drawing = require("hs.drawing")
local screen = require("hs.screen")
local Hotkey = require("hs.hotkey")

local obj = {}

obj.theGrid = {}

obj.textStyle = {
  font = {
    name = "System Font",
    size = 27
  },
  paragraphStyle = {
    alignment = "center"
  },
  color = drawing.color.colorsFor("System")["labelColor"],
  backgroundColor = drawing.color.colorsFor("System")["windowBackgroundColor"],
}

obj.hyper = {"cmd", "alt", "ctrl", "shift"}

obj.numberOfColumns = 8
obj.numberOfRows = 8
obj.boxWidth = nil
obj.boxHeight = nil

obj.keystrokesSent = ""
obj.hintCharacters = "asdfgqwertzxcvb"

obj.hintCharactersTable = {}
obj.mouseGridsModal = nil

function obj.buildGrid()
  -- build base grid
  local y = 0
  for _ = 1, obj.numberOfRows do
    local x = 0
    for _ = 1, obj.numberOfColumns do
      local singleRect =
        drawing.rectangle({x = x, y = y, w = obj.boxWidth, h = obj.boxHeight})
          :setFill(false)
          :setStroke(true)
          :setStrokeColor(drawing.color.colorsFor("System")["systemBlueColor"])
          :setStrokeWidth(3)
          :bringToFront(true)
          :setLevel(drawing.windowLevels._MaximumWindowLevelKey)
      table.insert(obj.theGrid, singleRect)
      x = x + obj.boxWidth
    end
    y = y + obj.boxHeight
  end

  -- assign hints to each box
  local hintsRequired = 0
  for _, _ in ipairs(obj.theGrid) do
    hintsRequired = hintsRequired + 1
  end
  local command = string.format([["/Users/roey/Dropbox/code/in_progress/hints.js" "%s" "%s"]], obj.hintCharacters, hintsRequired)
  local output = hs.execute(command)
  local hintsTable = Fnutils.split(output, "\n")
  for i, aSingleRect in ipairs(obj.theGrid) do
    local text = hintsTable[i]
    local singleRectangleFrame = aSingleRect:frame()
    local textFrame = drawing.getTextDrawingSize(text)
    local hintX = (singleRectangleFrame.x + ((singleRectangleFrame.w / 2) - (textFrame.w / 2)))
    local hintY = (singleRectangleFrame.y + ((singleRectangleFrame.h / 2) - (textFrame.h / 2)))
    local styledText = hs.styledtext.new(string.upper(text), obj.textStyle)
    aSingleRect.assignedHint = drawing.text({x = hintX, y = hintY, w = 50, h = 50}, styledText):setLevel(drawing.windowLevels._MaximumWindowLevelKey)
    aSingleRect.hintAsString = text
    aSingleRect.assignedHint.position = {x = hintX, y = hintY}
  end
end

function obj.handleKeyPress(theKey)
  obj.keystrokesSent = obj.keystrokesSent .. theKey
  print(obj.keystrokesSent, theKey)
  for _, box in ipairs(obj.theGrid) do
    if not string.find(box.hintAsString, theKey) then
      box.assignedHint:hide()
    end
    if obj.keystrokesSent == box.hintAsString then
      hs.eventtap.leftClick(box.assignedHint.position)
      obj.stop()
      return
    end
  end
end

function obj.start()
  for _, box in ipairs(obj.theGrid) do
    box:show(0.2)
    box.assignedHint:show(0.2)
  end
  obj.mouseGridsModal:enter()
  Hotkey.bind(obj.hyper, "m", function() obj.stop() end)
end

function obj.stop()
  obj.keystrokesSent = ""
  for _, box in ipairs(obj.theGrid) do
    box:hide(0.2)
    box.assignedHint:hide(0.2)
  end
  obj.mouseGridsModal:exit()
  Hotkey.bind(obj.hyper, "m", function() obj.start() end)
end

function obj.init()
  -- SETTINGS
  print("Building base grid...")
  obj.mouseGridsModal = hs.hotkey.modal.new()
  for char in string.gmatch(obj.hintCharacters, ".") do
    table.insert(obj.hintCharactersTable, char)
  end
  for _, key in ipairs(obj.hintCharactersTable) do
    obj.mouseGridsModal:bind({}, key, function() obj.handleKeyPress(key) end)
  end
  Hotkey.bind(obj.hyper, "m", function() obj.start() end)
  local mainScreen = screen.mainScreen():fullFrame()
  obj.boxWidth = mainScreen.w / obj.numberOfColumns
  obj.boxHeight = mainScreen.h / obj.numberOfRows
  if obj.theGrid[1] then
    return
  end
  obj.buildGrid()
end

return obj
