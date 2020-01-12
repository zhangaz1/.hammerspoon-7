local hs = hs
local Fnutils = require("hs.fnutils")
local drawing = require("hs.drawing")
local screen = require("hs.screen")
local Hotkey = require("hs.hotkey")
local StyledText = require("hs.styledtext")
local EventTap = require("hs.eventtap")

local obj = {}

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

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
obj.hintCharacters = "asdfgqwertzxcvb"
obj.keystrokesSent = ""
obj.hintCharactersTable = {}
obj.spoonPath = script_path()
obj.hintsScript = obj.spoonPath .. "/hints.js"

obj.theGrid = {}
obj.mouseGridsModal = nil

function obj:init()
  self.mouseGridsModal = Hotkey.modal.new()
  for char in string.gmatch(self.hintCharacters, ".") do
    table.insert(self.hintCharactersTable, char)
  end

  for _, character in ipairs(self.hintCharactersTable) do
    self.mouseGridsModal:bind(
      {},
      character,
      function()
        self:handleKeyPress(character)
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

  local mainScreen = screen.mainScreen():fullFrame()
  self.boxWidth = mainScreen.w / self.numberOfColumns
  self.boxHeight = mainScreen.h / self.numberOfRows
  self:buildGrid()
end

function obj:start()
  for _, box in ipairs(self.theGrid) do
    box:show(0.2)
    box.assignedHint:show(0.2)
  end
  self.mouseGridsModal:enter()
end

function obj:stop()
  self.keystrokesSent = ""
  for _, box in ipairs(self.theGrid) do
    box:hide(0.2)
    box.assignedHint:hide(0.2)
  end
  -- hs.timer.doAfter(
  --   0.3,
  --   function()
  --     for _, box in ipairs(self.theGrid) do
  --       box:delete()
  --       box.assignedHint:delete()
  --     end
  --     self.theGrid = {}
  --   end
  -- )
  self.mouseGridsModal:exit()
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
      )
      singleRect:setFill(false)
      singleRect:setStroke(true)
      singleRect:setStrokeColor(drawing.color.colorsFor("System")["systemBlueColor"])
      singleRect:setStrokeWidth(3)
      singleRect:bringToFront(true)
      singleRect:setLevel(drawing.windowLevels._MaximumWindowLevelKey)
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
    aSingleRect.assignedHint = drawing.text({x = hintX, y = hintY, w = 50, h = 50}, styledText)
    aSingleRect.assignedHint:setLevel(drawing.windowLevels._MaximumWindowLevelKey)
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

return obj
