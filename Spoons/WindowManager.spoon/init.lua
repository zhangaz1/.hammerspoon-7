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

local mainScreen = Screen.mainScreen()
local usableFrame = mainScreen:frame()
local fullFrame = mainScreen:fullFrame()
local menuBarHeight = fullFrame.h - usableFrame.h
local minX = usableFrame.x -- = 0.0
local midX = usableFrame.w / 2
local maxX = usableFrame.w
local minY = usableFrame.y -- not simply zero, because of the menu bar
local midY = usableFrame.h / 2
local maxY = usableFrame.h

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
    rect = Geometry.rect({minX, midY, midX, midY + menuBarHeight}),
    onLeft = "west",
    onRight = "southEast",
    onUp = "northWest",
    onDown = "south"
  },
  southEast = {
    rect = Geometry.rect({midX, midY, midX, midY + menuBarHeight}),
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
    rect = Geometry.rect({minX, midY, maxX, midY + menuBarHeight}),
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
      pushToCell("Left")
    end,
    pushRight = function()
      pushToCell("Right")
    end,
    pushDown = function()
      pushToCell("Down")
    end,
    pushUp = function()
      pushToCell("Up")
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
