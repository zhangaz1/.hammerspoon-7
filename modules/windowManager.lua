local hsgrid = require("hs.grid")
local hswindow = require("hs.window")
local hsgeometry = require("hs.geometry")
local hshotkey = require("hs.hotkey")
local drawing = require("hs.drawing")
local screen = require("hs.screen")

local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

hsgrid.setMargins(hsgeometry.point({0, 0}))
hsgrid.setGrid('2x2')

local obj = {}

local possibleCells = {
    {id = 'q1', rect = {0.0, 0.0, 1, 1}, onLeft = 'leftHalf', onRight = 'q2', onUp = 'upperHalf', onDown = 'q4'},
    {id = 'q2', rect = {1.0, 0.0, 1, 1}, onLeft = 'q1', onRight = 'rightHalf', onUp = 'upperHalf', onDown = 'q3'},
    {id = 'q3', rect = {1.0, 1.0, 1, 1}, onLeft = 'q4', onRight = 'rightHalf', onUp = 'q2', onDown = 'lowerHalf' },
    {id = 'q4', rect = {0.0, 1.0, 1, 1}, onLeft = 'leftHalf', onRight = 'q3', onUp = 'q1', onDown = 'lowerHalf' },
    {id = 'leftHalf', rect = {0.0, 0.0, 1, 2.0}, onLeft = 'fullScreen', onRight = 'rightHalf', onUp = 'q1', onDown = 'q4' },
    {id = 'rightHalf', rect = {1.0, 0.0, 1, 2.0}, onLeft = 'leftHalf', onRight = 'fullScreen', onUp = 'q2', onDown = 'q3' },
    {id = 'lowerHalf', rect = {0.0, 1.0, 2.0, 1}, onLeft = 'q4', onRight = 'q3', onUp = 'upperHalf', onDown = 'fullScreen' },
    {id = 'upperHalf', rect = {0.0, 0.0, 2.0, 1}, onLeft = 'q1', onRight = 'q2', onUp = 'fullScreen', onDown = 'lowerHalf' },
    {id = 'fullScreen', rect = {0.0, 0.0, 2.0, 2.0}, onLeft = 'leftHalf', onRight = 'rightHalf', onUp = 'upperHalf', onDown = 'lowerHalf' },
}

local function getCellIdByWindowSize(frontWindow)
    local cellSize = hsgrid.get(frontWindow)
    for _, v in pairs(possibleCells) do
        if hsgeometry.new(v.rect) == cellSize then
            return v
        end
    end
    return nil
end

local function setWindowSizeByCellId(frontWindow, cellType)
    for _, v in pairs(possibleCells) do
        if v.id == cellType then
            return hsgrid.set(frontWindow, v.rect)
        end
    end
    return nil
end

local function pushToGrid(direction)
    local frontWindow = hswindow.focusedWindow()
    local c = getCellIdByWindowSize(frontWindow)
    setWindowSizeByCellId(frontWindow, c['on' .. direction])
end

local function maximize()
    local frontWindow = hswindow.focusedWindow()
    local currentCell = getCellIdByWindowSize(frontWindow)
    if currentCell and currentCell.id == 'fullScreen' then
        setWindowSizeByCellId(frontWindow, 'q1')
        frontWindow:centerOnScreen()
    else
        setWindowSizeByCellId(frontWindow, 'fullScreen')
    end
end

local function center()
    hswindow.focusedWindow():centerOnScreen()
end

hshotkey.bind(hyper, "Up", function() pushToGrid('Up') end)
hshotkey.bind(hyper, "Down", function() pushToGrid('Down') end)
hshotkey.bind(hyper, "Right", function() pushToGrid('Right') end)
hshotkey.bind(hyper, "Left", function() pushToGrid('Left') end)
hshotkey.bind(hyper, "Return", function() maximize() end)
hshotkey.bind(hyper, "C", function() center() end)

--

local function move(direction)
    local point
    if direction == 'right' then
        point = {30, 0}
    elseif direction == 'left' then
        point = {-30, 0}
    elseif direction == 'up' then
        point = {0, -30}
    elseif direction == 'down' then
        point = {0, 30}
    end
    hswindow.focusedWindow():move(point)
end

local function resize(resizeKind)
    local rect
    local currentFrame = hswindow.focusedWindow():frame()
    local x = currentFrame._x
    local y = currentFrame._y
    local w = currentFrame._w
    local h = currentFrame._h
    if resizeKind == "growToRight" then
        rect = {x = x, y = y, w = w + 30, h = h}
    elseif resizeKind == "growToBottom" then
        rect = {x = x, y = y, w = w, h = h + 30}
    elseif resizeKind == "shrinkFromRight" then
        rect = {x = x, y = y, w = w - 30, h = h}
    elseif resizeKind == "shrinkFromBottom" then
        rect = {x = x, y = y, w = w, h = h - 30}
    end
    hswindow.focusedWindow():setFrame(hsgeometry.rect(rect))
end

obj.keyMap = [[
↑ Move Up
↓ Move Down
→ Move Right
← Move Left
⌃← Shrink from Right
⌃→ Shrink from Left
⌃↑ Shrink from Bottom
⌃↓ Shrink from Top
⌘← Grow to Left
⌘→ Grow to Right
⌘↑ Grow to Top
⌘↓ Grow to Bottom
]]

local background

obj.textObject = nil
obj.textFrame = nil
obj.textStyle = { size = 27, alignment = "center" }

local function enterModal()

    obj.windowManagerModal:enter()

    local currentScreenFrame = screen.mainScreen():frame()
    local currentScreenHorizontalCenter = (currentScreenFrame.w / 2)
    local currentScreenVerticalCenter = (currentScreenFrame.h / 2)

    obj.textFrame = drawing.getTextDrawingSize(obj.keyMap, obj.textStyle)

    background = drawing.rectangle({
        w = obj.textFrame.w + 50,
        h = obj.textFrame.h + 50,
        x = currentScreenHorizontalCenter - ((obj.textFrame.w + 50) / 2),
        y = currentScreenVerticalCenter - ((obj.textFrame.h + 50) / 2)
    })
        :setRoundedRectRadii(15, 15)
        :setStroke(false)
        :setFillColor({hex = "#3a3a3c", alpha = "0.5"})
        :bringToFront(true)
        :show()




    obj.textObject = drawing.text({
        w = obj.textFrame.w + 5, -- safety buffer
        h = obj.textFrame.h + 5, -- safety buffer
        x = currentScreenHorizontalCenter - (obj.textFrame.w / 2),
        y = currentScreenVerticalCenter - (obj.textFrame.h / 2)
    }, obj.keyMap)
        :bringToFront(true)
        :show()
end

local function destroyModal()
    background:delete()
    obj.textObject:delete()
    obj.windowManagerModal:exit()
end



obj.windowManagerModal = hshotkey.modal.new()
obj.windowManagerModal:bind(hyper, "w", function() destroyModal() end)
obj.windowManagerModal:bind({}, "return", function() destroyModal() end)
obj.windowManagerModal:bind({}, "escape", function() destroyModal() end)
obj.windowManagerModal:bind({}, "up", function() move('up') end, nil, function() move('up') end)
obj.windowManagerModal:bind({}, "down", function() move('down') end, nil, function() move('down') end)
obj.windowManagerModal:bind({}, "right", function() move('right') end, nil, function() move('right') end)
obj.windowManagerModal:bind({}, "left", function() move('left') end, nil, function() move('left') end)

obj.windowManagerModal:bind({"cmd"}, "right", function() resize("growToRight") end, nil, function() resize("growToRight") end)
obj.windowManagerModal:bind({"cmd"}, "down", function() resize("growToBottom") end, nil, function() resize("growToBottom") end)
obj.windowManagerModal:bind({"shift", "cmd"}, "left", function() resize("shrinkFromRight") end, nil, function() resize("shrinkFromRight") end)
obj.windowManagerModal:bind({"shift", "cmd"}, "up", function() resize("shrinkFromBottom") end, nil, function() resize("shrinkFromBottom") end)

hshotkey.bind(hyper, "w", function()
    enterModal()
end)
