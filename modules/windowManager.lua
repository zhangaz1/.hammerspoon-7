local Grid = require("hs.grid")
local hswindow = require("hs.window")
local hsgeometry = require("hs.geometry")
local hotkey = require("hs.hotkey")
local HSScreen = require("hs.screen")

local obj = {}
local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

-- OPTIONS
local grid = nil

-- POSSIBLE CELLS --
obj.possibleCells = {
    {id = 'q1', rect = {0.0, 0.0, 1.0, 1.0}, onLeft = 'leftHalf', onRight = 'q2', onUp = 'upperHalf', onDown = 'q4'},
    {id = 'q2', rect = {1.0, 0.0, 1.0, 1.0}, onLeft = 'q1', onRight = 'rightHalf', onUp = 'upperHalf', onDown = 'q3'},
    {id = 'q3', rect = {1.0, 1.0, 1.0, 1.0}, onLeft = 'q4', onRight = 'rightHalf', onUp = 'q2', onDown = 'lowerHalf' },
    {id = 'q4', rect = {0.0, 1.0, 1.0, 1.0}, onLeft = 'leftHalf', onRight = 'q3', onUp = 'q1', onDown = 'lowerHalf' },
    {id = 'leftHalf', rect = {0.0, 0.0, 1.0, 2.0}, onLeft = 'fullScreen', onRight = 'rightHalf', onUp = 'q1', onDown = 'q4' },
    {id = 'rightHalf', rect = {1.0, 0.0, 1.0, 2.0}, onLeft = 'leftHalf', onRight = 'fullScreen', onUp = 'q2', onDown = 'q3' },
    {id = 'lowerHalf', rect = {0.0, 1.0, 2.0, 1.0}, onLeft = 'q4', onRight = 'q3', onUp = 'upperHalf', onDown = 'fullScreen' },
    {id = 'upperHalf', rect = {0.0, 0.0, 2.0, 1.0}, onLeft = 'q1', onRight = 'q2', onUp = 'fullScreen', onDown = 'lowerHalf' },
    {id = 'fullScreen', rect = {0.0, 0.0, 2.0, 2.0}, onLeft = 'leftHalf', onRight = 'rightHalf', onUp = 'upperHalf', onDown = 'lowerHalf' },
}

hotkey.bind(hyper, "Up", function() obj.pushToCell('Up', 'upperHalf') end)
hotkey.bind(hyper, "Down", function() obj.pushToCell('Down', 'lowerHalf') end)
hotkey.bind(hyper, "Right", function() obj.pushToCell('Right', 'rightHalf') end)
hotkey.bind(hyper, "Left", function() obj.pushToCell('Left', 'leftHalf') end)
hotkey.bind(hyper, "Return", function() obj.maximize() end)
hotkey.bind(hyper, "C", function() hswindow.focusedWindow():centerOnScreen() end)

obj.pushToCell = function(direction, fallBack)
    grid = Grid.setMargins(hsgeometry.point({0, 0})).setGrid('2x2', HSScreen.mainScreen(), nil)
    local frontWindow = hswindow.focusedWindow()
    local cellObject = obj.getCellObjectByWindowSize(frontWindow)
    -- print(cellObject.id)
    if cellObject and cellObject.id then
        obj.setWindowSizeByCellId(frontWindow, cellObject['on'..direction])
    else
        obj.setWindowSizeByCellId(frontWindow, fallBack)
    end
end

obj.maximize = function()
    grid = Grid.setMargins(hsgeometry.point({0, 0})).setGrid('2x2', HSScreen.mainScreen(), nil)
    local frontWindow = hswindow.focusedWindow()
    local currentCell = obj.getCellObjectByWindowSize(frontWindow)
    if currentCell and currentCell.id == 'fullScreen' then
        obj.setWindowSizeByCellId(frontWindow, 'q1')
        frontWindow:centerOnScreen()
    else
        obj.setWindowSizeByCellId(frontWindow, 'fullScreen')
    end
end

obj.getCellObjectByWindowSize = function(frontWindow)
    local mainScreen = HSScreen.mainScreen()
    local frameForCurrentWindow = frontWindow:frame()
    for _, possibleCell in pairs(obj.possibleCells) do
        local frameForPossibleCell = grid.getCell(possibleCell.rect, mainScreen)
        if obj.compareTables(frameForCurrentWindow, frameForPossibleCell) then
            return possibleCell
        end
    end
    return nil
end

obj.setWindowSizeByCellId = function(frontWindow, cellID)
    for _, possibleCell in pairs(obj.possibleCells) do
        if possibleCell.id == cellID then
            return grid.set(frontWindow, possibleCell.rect)
        end
    end
end

obj.compareTables = function(table1, table2)
    if math.floor(math.abs(table1.x)) == math.floor(math.abs(table2.x)) and
    math.floor(math.abs(table1.y)) == math.floor(math.abs(table2.y)) and
    math.floor(math.abs(table1.w)) == math.floor(math.abs(table2.w)) and
    math.floor(math.abs(table1.h)) == math.floor(math.abs(table2.h))
    then
        return true
    else
        return false
    end
end
