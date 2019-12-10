local Grid = require("hs.grid")
local Window = require("hs.window")
local Geometry = require("hs.geometry")
local Hotkey = require("hs.hotkey")
local Screen = require("hs.screen")
local FNUtils = require("hs.fnutils")
local Drawing = require("hs.drawing")

local obj = {}

-- POSSIBLE CELLS --
obj.possibleCells = {
    {
        id = "northWest",
        rect = {0.0, 0.0, 1.0, 1.0},
        onLeft = "west",
        onRight = "northEast",
        onUp = "north",
        onDown = "southEast",
        -- counterpart = "northEast"
    },
    {
        id = "northEast",
        rect = {1.0, 0.0, 1.0, 1.0},
        onLeft = "northWest",
        onRight = "east",
        onUp = "north",
        onDown = "southWest",
        -- counterpart = "northWest"
    },
    {
        id = "southWest",
        rect = {1.0, 1.0, 1.0, 1.0},
        onLeft = "southEast",
        onRight = "east",
        onUp = "northEast",
        onDown = "south"
    },
    {
        id = "southEast",
        rect = {0.0, 1.0, 1.0, 1.0},
        onLeft = "west",
        onRight = "southWest",
        onUp = "northWest",
        onDown = "south"
    },
    {
        id = "west",
        rect = {0.0, 0.0, 1.0, 2.0},
        onLeft = "fullScreen",
        onRight = "east",
        onUp = "northWest",
        onDown = "southEast",
        -- counterpart = "east"
    },
    {
        id = "east",
        rect = {1.0, 0.0, 1.0, 2.0},
        onLeft = "west",
        onRight = "fullScreen",
        onUp = "northEast",
        onDown = "southWest",
        -- counterpart = "west"
    },
    {
        id = "south",
        rect = {0.0, 1.0, 2.0, 1.0},
        onLeft = "southEast",
        onRight = "southWest",
        onUp = "north",
        onDown = "fullScreen"
    },
    {
        id = "north",
        rect = {0.0, 0.0, 2.0, 1.0},
        onLeft = "northWest",
        onRight = "northEast",
        onUp = "fullScreen",
        onDown = "south"
    },
    {
        id = "fullScreen",
        rect = {0.0, 0.0, 2.0, 2.0},
        onLeft = "west",
        onRight = "east",
        onUp = "north",
        onDown = "south"
    }
}

local function blue()
    return Drawing.color.lists()["System"]["systemBlueColor"]
end

obj.overlay = {
    fill = Drawing.rectangle({0, 0, 0, 0})
        :setLevel(Drawing.windowLevels["_MaximumWindowLevelKey"])
        :setFill(true)
        :setFillColor(blue())
        :setAlpha(0.2)
        :setRoundedRectRadii(3, 3),
    stroke = Drawing.rectangle({0, 0, 0, 0})
        :setLevel(Drawing.windowLevels["_MaximumWindowLevelKey"])
        :setFill(false)
        :setStrokeWidth(15)
        :setStrokeColor(blue())
        :setStroke(true)
        :setRoundedRectRadii(3, 3),
    show = function(dimensions)
        for _,v in ipairs({obj.overlay.fill, obj.overlay.stroke}) do
            if v and v.hide then
                v:setFrame(dimensions):show(0.2)
            end
        end
    end,
    hide = function()
        for _,v in ipairs({obj.overlay.fill, obj.overlay.stroke}) do
            if v and v.hide then
                v:setFrame({0, 0, 0, 0}):hide(0.2)
            end
        end
    end
}

function obj.defaultGrid()
    return Grid.setMargins(Geometry.point({0, 0})).setGrid("2x2", obj.getMainScreen(), nil)
end

function obj.getMainScreen()
    return Screen.mainScreen()
end

function obj.pushToCell(direction, fallBack)
    local frontWindow = Window.focusedWindow()
    local cellObject = obj.getCellObjectByWindowSize(frontWindow)
    -- print(cellObject.id)
    local targetCell
    if cellObject then
        targetCell = cellObject["on" .. direction]
    else
        targetCell = fallBack
    end
    obj.setWindowSizeByCellId(frontWindow, targetCell)
end

function obj.maximize()
    local frontWindow = Window.focusedWindow()
    local currentCell = obj.getCellObjectByWindowSize(frontWindow)
    if currentCell and currentCell.id == "fullScreen" then
        obj.setWindowSizeByCellId(frontWindow, "northWest")
        frontWindow:centerOnScreen()
    else
        obj.setWindowSizeByCellId(frontWindow, "fullScreen")
    end
end

function obj.getCellObjectByWindowSize(frontWindow)
    local mainScreen = obj.getMainScreen()
    local frameForCurrentWindow = frontWindow:frame()
    for _, possibleCell in pairs(obj.possibleCells) do
        local frameForPossibleCell = obj.defaultGrid().getCell(possibleCell.rect, mainScreen)
        -- TODO: direct comparison between possibleCell.rect and hs.grid.get(frontWindow)?
        if obj.compareTables(frameForCurrentWindow, frameForPossibleCell) then
            return possibleCell
        end
    end
    return nil
end

function obj.setWindowSizeByCellId(frontWindow, cellID)
    for _, possibleCell in pairs(obj.possibleCells) do
        if possibleCell.id == cellID then
            obj.defaultGrid().set(frontWindow, possibleCell.rect)
            if possibleCell.counterpart then
                obj.paintOverlay(possibleCell.counterpart)
            else
                obj.overlay.hide()
            end
            return
        end
    end
end

function obj.compareTables(table1, table2)
    local function fn(x)
        return math.floor(math.abs(x))
    end
    -- print(hs.inspect(table1), hs.inspect(table2))
    table1 = FNUtils.map(table1, fn)
    table2 = FNUtils.map(table2, fn)
    if table1._x == table2.x and table1._y == table2.y and table1._w == table2.w and table1._h == table2.h then
        return true
    else
        return false
    end
end

function obj.paintOverlay(counterpartID)
    local mainScreen = obj.getMainScreen()
    for _, possibleCell in ipairs(obj.possibleCells) do
        if possibleCell.id == counterpartID then
            local overlayDimensions = obj.defaultGrid().getCell(possibleCell.rect, mainScreen)
            obj.overlay.show(overlayDimensions)
        end
    end
end

-- BINDINGS --
local hyper = {"cmd", "alt", "ctrl", "shift"}
Hotkey.bind(
    hyper,
    "up",
    function()
        obj.pushToCell("Up", "north")
    end
)
Hotkey.bind(
    hyper,
    "down",
    function()
        obj.pushToCell("Down", "south")
    end
)
Hotkey.bind(
    hyper,
    "right",
    function()
        obj.pushToCell("Right", "east")
    end
)
Hotkey.bind(
    hyper,
    "left",
    function()
        obj.pushToCell("Left", "west")
    end
)
Hotkey.bind(
    hyper,
    "return",
    function()
        obj.maximize()
    end
)
Hotkey.bind(
    hyper,
    "c",
    function()
        Window.focusedWindow():centerOnScreen()
    end
)

return obj
