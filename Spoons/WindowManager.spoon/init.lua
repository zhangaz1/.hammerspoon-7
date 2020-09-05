local Window = require("hs.window")
local Screen = require("hs.screen")
local Geometry = require("hs.geometry")
local Spoons = require("hs.spoons")

local obj = {}

obj.__index = obj
obj.name = "WindowManager"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local screenFrame = Screen.mainScreen():frame()
local minX = screenFrame.x -- not simply zero, because of the menu bar
local midX = screenFrame.w / 2
local maxX = screenFrame.w
local minY = screenFrame.y
local midY = screenFrame.h / 2
local maxY = screenFrame.h

-- POSSIBLE CELLS --
local possibleCells = {
  northWest = {
    rect = Geometry.rect({minX, minY, midX, midY}),
    onLeft = "west",
    onRight = "northEast",
    onUp = "north",
    onDown = "southWest"
  },
  northEast = {
    rect = Geometry.rect({midX, minY, midX, midY}),
    onLeft = "northWest",
    onRight = "east",
    onUp = "north",
    onDown = "southEast"
  },
  southWest = {
    rect = Geometry.rect({minX, midY, midX, midY}),
    onLeft = "west",
    onRight = "southEast",
    onUp = "northWest",
    onDown = "south"
  },
  southEast = {
    rect = Geometry.rect({midX, midY, midX, midY}),
    onLeft = "southWest",
    onRight = "east",
    onUp = "northEast",
    onDown = "south"
  },
  west = {
    rect = Geometry.rect({minX, minY, midX, maxY}),
    onLeft = "fullScreen",
    onRight = "east",
    onUp = "northWest",
    onDown = "southWest"
  },
  east = {
    rect = Geometry.rect({midX, minY, midX, maxY}),
    onLeft = "west",
    onRight = "fullScreen",
    onUp = "northEast",
    onDown = "southEast"
  },
  south = {
    rect = Geometry.rect({minX, midY, maxX, midY}),
    onLeft = "southWest",
    onRight = "southEast",
    onUp = "north",
    onDown = "fullScreen"
  },
  north = {
    rect = Geometry.rect({minX, minY, maxX, midY}),
    onLeft = "northWest",
    onRight = "northEast",
    onUp = "fullScreen",
    onDown = "south"
  },
  fullScreen = {
    rect = Geometry.rect({minX, minY, maxX, maxY}),
    onLeft = "west",
    onRight = "east",
    onUp = "north",
    onDown = "south"
  }
}

local fallbacks = {Up = "north", Down = "south", Right = "east", Left = "west"}

local function pushToCell(direction)
  local frontWindow = Window.frontmostWindow()
  local frontWindowFrame = frontWindow:frame()
  -- local targetCell
  for _, cellProperties in pairs(possibleCells) do
    if frontWindowFrame:equals(cellProperties.rect) then
      local targetCellName = cellProperties["on" .. direction]
      local targetCell = possibleCells[targetCellName].rect
      frontWindow:setFrame(targetCell)
      return
    end
  end
  local targetCellName = fallbacks[direction]
  frontWindow:setFrame(possibleCells[targetCellName].rect)
end

local function pushLeft()
  pushToCell("Left")
end

local function pushDown()
  pushToCell("Down")
end

local function pushUp()
  pushToCell("Up")
end

local function pushRight()
  pushToCell("Right")
end

local function maximize()
  local frontWindow = Window.frontmostWindow()
  local frontWindowFrame = frontWindow:frame()
  if frontWindowFrame:equals(possibleCells.fullScreen.rect) then
    frontWindow:setFrame(possibleCells.northWest.rect)
    frontWindow:centerOnScreen()
  else
    frontWindow:setFrame(possibleCells.fullScreen.rect)
  end
end

function obj:bindHotKeys(_mapping)
  local def = {
    maximize = function()
      maximize()
    end,
    pushLeft = function()
      pushLeft()
    end,
    pushRight = function()
      pushRight()
    end,
    pushDown = function()
      pushDown()
    end,
    pushUp = function()
      pushUp()
    end
  }
  Spoons.bindHotkeysToSpec(def, _mapping)
end

return obj

-- obj.overlay = {
--   fill = Drawing.rectangle({0, 0, 0, 0}):setLevel(Drawing.windowLevels["_MaximumWindowLevelKey"]):setFill(true):setFillColor(
--     getSystemBlueColor()
--   ):setAlpha(0.2):setRoundedRectRadii(3, 3),
--   stroke = Drawing.rectangle({0, 0, 0, 0}):setLevel(Drawing.windowLevels["_MaximumWindowLevelKey"]):setFill(false):setStrokeWidth(
--     15
--   ):setStrokeColor(getSystemBlueColor()):setStroke(true):setRoundedRectRadii(3, 3),
--   show = function(dimensions)
--     for _, v in ipairs({obj.overlay.fill, obj.overlay.stroke}) do
--       if v and v.hide then
--         v:setFrame(dimensions):show(0.2)
--       end
--     end
--   end,
--   hide = function()
--     for _, v in ipairs({obj.overlay.fill, obj.overlay.stroke}) do
--       if v and v.hide then
--         v:setFrame({0, 0, 0, 0}):hide(0.2)
--       end
--     end
--   end
-- }

-- local function getSystemBlueColor()
--   return Drawing.color.lists()["System"]["systemBlueColor"]
-- end

--   local mainScreen = getMainScreen()
--   for _, possibleCell in ipairs(possibleCells) do
--       local overlayDimensions = defaultGrid().getCell(possibleCell.rect, mainScreen)
--       obj.overlay.show(overlayDimensions)
--     end
--   end
-- end

-- print("Entering transient modal...")
-- hs.timer.doAfter(0.5, function() tabBind:disable() end)
-- end
