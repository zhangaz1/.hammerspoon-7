local Grid = require("hs.grid")
local Window = require("hs.window")
local Geometry = require("hs.geometry")
local Screen = require("hs.screen")
local FNUtils = require("hs.fnutils")
local Drawing = require("hs.drawing")

local obj = {}

obj.__index = obj
obj.name = "WindowManager"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- POSSIBLE CELLS --
obj.possibleCells = {
  {
    id = "northWest",
    rect = {0.0, 0.0, 1.0, 1.0},
    onLeft = "west",
    onRight = "northEast",
    onUp = "north",
    onDown = "southEast",
    counterpart = "northEast"
  }, {
    id = "northEast",
    rect = {1.0, 0.0, 1.0, 1.0},
    onLeft = "northWest",
    onRight = "east",
    onUp = "north",
    onDown = "southWest",
    counterpart = "northWest"
  }, {
    id = "southWest",
    rect = {1.0, 1.0, 1.0, 1.0},
    onLeft = "southEast",
    onRight = "east",
    onUp = "northEast",
    onDown = "south",
    counterpart = "southEast"
  }, {
    id = "southEast",
    rect = {0.0, 1.0, 1.0, 1.0},
    onLeft = "west",
    onRight = "southWest",
    onUp = "northWest",
    onDown = "south",
    counterpart = "southWest"
  }, {
    id = "west",
    rect = {0.0, 0.0, 1.0, 2.0},
    onLeft = "fullScreen",
    onRight = "east",
    onUp = "northWest",
    onDown = "southEast",
    counterpart = "east"
  }, {
    id = "east",
    rect = {1.0, 0.0, 1.0, 2.0},
    onLeft = "west",
    onRight = "fullScreen",
    onUp = "northEast",
    onDown = "southWest",
    counterpart = "west"
  }, {
    id = "south",
    rect = {0.0, 1.0, 2.0, 1.0},
    onLeft = "southEast",
    onRight = "southWest",
    onUp = "north",
    onDown = "fullScreen",
    counterpart = "north"
  }, {
    id = "north",
    rect = {0.0, 0.0, 2.0, 1.0},
    onLeft = "northWest",
    onRight = "northEast",
    onUp = "fullScreen",
    onDown = "south",
    counterpart = "south"
  },
  {id = "fullScreen", rect = {0.0, 0.0, 2.0, 2.0}, onLeft = "west", onRight = "east", onUp = "north", onDown = "south"}
}

local fallbacks = {Up = "north", Down = "south", Right = "east", Left = "west"}
local function getSystemBlueColor() return Drawing.color.lists()["System"]["systemBlueColor"] end
local function getMainScreen() return Screen.mainScreen() end
local function defaultGrid() return Grid.setMargins(Geometry.point({0, 0})).setGrid("2x2", getMainScreen(), nil) end

local function paintOverlay(counterpartID)
  local mainScreen = getMainScreen()
  for _, possibleCell in ipairs(obj.possibleCells) do
    if possibleCell.id == counterpartID then
      local overlayDimensions = defaultGrid().getCell(possibleCell.rect, mainScreen)
      obj.overlay.show(overlayDimensions)
    end
  end
end

local function secondWindowTimedOppurtunity(counterpart)
  -- print("Entering transient modal...")
  -- local tabBind = hs.hotkey.bind({}, "tab", function() paintOverlay(counterpart) end)
  -- hs.timer.doAfter(0.5, function() tabBind:disable() end)
end

local function setWindowSizeByCellId(frontWindow, cellID)
  for _, possibleCell in pairs(obj.possibleCells) do
    if possibleCell.id == cellID then
      defaultGrid().set(frontWindow, possibleCell.rect)
      -- begin second window sequence, if a counter part is defined
      obj.overlay.hide()
      if possibleCell.counterpart then
        secondWindowTimedOppurtunity(possibleCell.counterpart)
      end
      return
    end
  end
end

local function compareTables(table1, table2)
  local function fn(x) return math.floor(math.abs(x)) end
  -- print(hs.inspect(table1), hs.inspect(table2))
  table1 = FNUtils.map(table1, fn)
  table2 = FNUtils.map(table2, fn)
  if table1._x == table2.x and table1._y == table2.y and table1._w == table2.w and table1._h == table2.h then
    return true
  else
    return false
  end
end

local function getCellObjectByWindowSize(frontWindow)
  local mainScreen = getMainScreen()
  local frameForCurrentWindow = frontWindow:frame()
  for _, possibleCell in pairs(obj.possibleCells) do
    local frameForPossibleCell = defaultGrid().getCell(possibleCell.rect, mainScreen)
    -- TODO: direct comparison between possibleCell.rect and hs.grid.get(frontWindow)?
    if compareTables(frameForCurrentWindow, frameForPossibleCell) then return possibleCell end
  end
  return nil
end

obj.overlay = {
  fill = Drawing.rectangle({0, 0, 0, 0}):setLevel(Drawing.windowLevels["_MaximumWindowLevelKey"]):setFill(true)
    :setFillColor(getSystemBlueColor()):setAlpha(0.2):setRoundedRectRadii(3, 3),
  stroke = Drawing.rectangle({0, 0, 0, 0}):setLevel(Drawing.windowLevels["_MaximumWindowLevelKey"]):setFill(false)
    :setStrokeWidth(15):setStrokeColor(getSystemBlueColor()):setStroke(true):setRoundedRectRadii(3, 3),
  show = function(dimensions)
    for _, v in ipairs({obj.overlay.fill, obj.overlay.stroke}) do
      if v and v.hide then v:setFrame(dimensions):show(0.2) end
    end
  end,
  hide = function()
    for _, v in ipairs({obj.overlay.fill, obj.overlay.stroke}) do
      if v and v.hide then v:setFrame({0, 0, 0, 0}):hide(0.2) end
    end
  end
}

function obj.pushToCell(direction)
  local frontWindow = Window.focusedWindow()
  local cellObject = getCellObjectByWindowSize(frontWindow)
  -- print(cellObject.id)
  local targetCell
  if cellObject then
    targetCell = cellObject["on" .. direction]
  else
    targetCell = fallbacks[direction]
  end
  setWindowSizeByCellId(frontWindow, targetCell)
end

function obj.maximize()
  local frontWindow = Window.focusedWindow()
  local currentCell = getCellObjectByWindowSize(frontWindow)
  if currentCell and currentCell.id == "fullScreen" then
    setWindowSizeByCellId(frontWindow, "northWest")
    frontWindow:centerOnScreen()
  else
    setWindowSizeByCellId(frontWindow, "fullScreen")
  end
end

return obj
