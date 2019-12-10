local hs = hs
local Fnutils = require("hs.fnutils")
local drawing = require("hs.drawing")
local screen = require("hs.screen")
local Hotkey = require("hs.hotkey")
local StyledText = require("hs.styledtext")
local EventTap = require("hs.eventtap")

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
  backgroundColor = drawing.color.colorsFor("System")["windowBackgroundColor"]
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

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
obj.spoonPath = script_path()
obj.hintsScript = obj.spoonPath .. "/hints.js"

function obj:init()
  self.mouseGridsModal = Hotkey.modal.new()
  for char in string.gmatch(self.hintCharacters, ".") do
    table.insert(self.hintCharactersTable, char)
  end

  for _, key in ipairs(self.hintCharactersTable) do
    self.mouseGridsModal:bind(
      {},
      key,
      function()
        self:handleKeyPress(key)
      end
    )
  end

  for _, hotkey in ipairs(
    {
      {self.hyper, "m"},
      {{}, "escape"},
      {{}, "return"}
    }
  ) do
    self.mouseGridsModal:bind(
      hotkey[1],
      hotkey[2],
      nil,
      function()
        self:stop()
      end
    )
  end

  Hotkey.bind(
    self.hyper,
    "m",
    function()
      obj:start()
    end
  )

  local mainScreen = screen.mainScreen():fullFrame()
  self.boxWidth = mainScreen.w / self.numberOfColumns
  self.boxHeight = mainScreen.h / self.numberOfRows
  if self.theGrid[1] then
    return
  end
  self:buildGrid()
end

function obj:start()
  for _, box in ipairs(self.theGrid) do
    box:show(0.2)
    box.assignedHint:show(0.2)
  end
  self.mouseGridsModal:enter()
end

function obj:buildGrid()
  -- build base grid
  local y = 0
  for _ = 1, self.numberOfRows do
    local x = 0
    for _ = 1, self.numberOfColumns do
      local singleRect =
        drawing.rectangle(
        {
          x = x,
          y = y,
          w = self.boxWidth,
          h = self.boxHeight
        }
      ):setFill(false):setStroke(true):setStrokeColor(drawing.color.colorsFor("System")["systemBlueColor"]):setStrokeWidth(
        3
      ):bringToFront(true):setLevel(drawing.windowLevels._MaximumWindowLevelKey)
      table.insert(self.theGrid, singleRect)
      x = x + self.boxWidth
    end
    y = y + self.boxHeight
  end

  -- assign hints to each box
  local hintsRequired = 0
  for _, _ in ipairs(self.theGrid) do
    hintsRequired = hintsRequired + 1
  end
  local command = string.format([["%s" "%s" "%s"]], self.hintsScript, self.hintCharacters, hintsRequired)
  local output = hs.execute(command)
  local hintsTable = Fnutils.split(output, "\n")
  for i, aSingleRect in ipairs(self.theGrid) do
    local text = hintsTable[i]
    local singleRectangleFrame = aSingleRect:frame()
    local textFrame = drawing.getTextDrawingSize(text)
    local hintX = (singleRectangleFrame.x + ((singleRectangleFrame.w / 2) - (textFrame.w / 2)))
    local hintY = (singleRectangleFrame.y + ((singleRectangleFrame.h / 2) - (textFrame.h / 2)))
    local styledText = StyledText.new(string.upper(text), self.textStyle)
    aSingleRect.assignedHint =
      drawing.text({x = hintX, y = hintY, w = 50, h = 50}, styledText):setLevel(
      drawing.windowLevels._MaximumWindowLevelKey
    )
    aSingleRect.hintAsString = text
    aSingleRect.assignedHint.position = {x = hintX, y = hintY}
  end
end

function obj:handleKeyPress(theKey)
  self.keystrokesSent = self.keystrokesSent .. theKey
  for _, box in ipairs(self.theGrid) do
    if not string.find(box.hintAsString, theKey) then
      box.assignedHint:hide()
    end
    if self.keystrokesSent == box.hintAsString then
      EventTap.leftClick(box.assignedHint.position)
      self:stop()
      return
    end
  end
end

function obj:stop()
  self.keystrokesSent = ""
  for _, box in ipairs(self.theGrid) do
    box:hide(0.2)
    box.assignedHint:hide(0.2)
  end
  self.mouseGridsModal:exit()
end

return obj
