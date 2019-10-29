local hsgrid = require("hs.grid")
local hswindow = require("hs.window")
local hsgeometry = require("hs.geometry")
local hotkey = require("hs.hotkey")
local drawing = require("hs.drawing")
local screen = require("hs.screen")

local obj = {}

hsgrid.setMargins(hsgeometry.point({0, 0}))
hsgrid.setGrid('2x2')

local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

obj.windowManagerModal = hotkey.modal.new()
    :bind(hyper, "w", function() obj.destroyModal() end)
    :bind({}, "return", function() obj.destroyModal() end)
    :bind({}, "escape", function() obj.destroyModal() end)
    :bind({}, "up", function() obj.move('up') end, nil, function() obj.move('up') end)
    :bind({}, "down", function() obj.move('down') end, nil, function() obj.move('down') end)
    :bind({}, "right", function() obj.move('right') end, nil, function() obj.move('right') end)
    :bind({}, "left", function() obj.move('left') end, nil, function() obj.move('left') end)
    :bind({"cmd"}, "right", function() obj.resize("growToRight") end, nil, function() obj.resize("growToRight") end)
    :bind({"cmd"}, "down", function() obj.resize("growToBottom") end, nil, function() obj.resize("growToBottom") end)
    :bind({"shift", "cmd"}, "left", function() obj.resize("shrinkFromRight") end, nil, function() obj.resize("shrinkFromRight") end)
    :bind({"shift", "cmd"}, "up", function() obj.resize("shrinkFromBottom") end, nil, function() obj.resize("shrinkFromBottom") end)

hotkey.bind(hyper, "Up", function() obj.pushToGrid('Up') end)
hotkey.bind(hyper, "Down", function() obj.pushToGrid('Down') end)
hotkey.bind(hyper, "Right", function() obj.pushToGrid('Right') end)
hotkey.bind(hyper, "Left", function() obj.pushToGrid('Left') end)
hotkey.bind(hyper, "Return", function() obj.maximize() end)
hotkey.bind(hyper, "C", function() obj.center() end)

hotkey.bind(hyper, "w", function()
    obj.enterModal()
end)

obj.possibleCells = {
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

obj.getCellIdByWindowSize = function(frontWindow)
    local cellSize = hsgrid.get(frontWindow)
    for _, v in pairs(obj.possibleCells) do
        if hsgeometry.new(v.rect) == cellSize then
            return v
        end
    end
    return nil
end

obj.setWindowSizeByCellId = function(frontWindow, cellType)
    for _, v in pairs(obj.possibleCells) do
        if v.id == cellType then
            return hsgrid.set(frontWindow, v.rect)
        end
    end
    return nil
end

obj.pushToGrid = function(direction)
    local frontWindow = hswindow.focusedWindow()
    local c = obj.getCellIdByWindowSize(frontWindow)
    obj.setWindowSizeByCellId(frontWindow, c['on' .. direction])
end

obj.maximize = function()
    local frontWindow = hswindow.focusedWindow()
    local currentCell = obj.getCellIdByWindowSize(frontWindow)
    if currentCell and currentCell.id == 'fullScreen' then
        obj.setWindowSizeByCellId(frontWindow, 'q1')
        frontWindow:centerOnScreen()
    else
        obj.setWindowSizeByCellId(frontWindow, 'fullScreen')
    end
end

obj.center = function()
    hswindow.focusedWindow():centerOnScreen()
end

obj.move = function(direction)
    local point
    if direction == 'right' then
        point = {60, 0}
    elseif direction == 'left' then
        point = {-60, 0}
    elseif direction == 'up' then
        point = {0, -60}
    elseif direction == 'down' then
        point = {0, 60}
    end
    hswindow.focusedWindow():move(point)
end

obj.resize = function(resizeKind)
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

obj.background = nil
obj.actualText = nil

obj.createGui = function()
    local mainScreen = screen.mainScreen():frame()
    local screenHorizCenter = (mainScreen.w / 2)
    local screenVertCenter = (mainScreen.h / 2)

    local textFrame = drawing.getTextDrawingSize(obj.keyMap, {
        size = 27,
        alignment = "center"
    })

    obj.actualText = drawing.text({
        w = textFrame.w + 5, -- safety buffer
        h = textFrame.h + 5, -- safety buffer
        x = screenHorizCenter - (textFrame.w / 2),
        y = screenVertCenter - (textFrame.h / 2)
    }, obj.keyMap):bringToFront(true)

    obj.background = drawing.rectangle({
       w = textFrame.w + 50,
       h = textFrame.h + 50,
       x = screenHorizCenter - ((textFrame.w + 50) / 2),
       y = screenVertCenter - ((textFrame.h + 50) / 2)
       })
       :setRoundedRectRadii(15, 15)
       :setStroke(false)
       :setFillColor({hex = "#3a3a3c", alpha = "0.5"})
       :bringToFront(true)
end


obj.enterModal = function()
    obj.windowManagerModal:enter()
    obj.createGui()
    obj.background:show()
    obj.actualText:show()
end

obj.destroyModal = function()
    obj.windowManagerModal:exit()
    obj.background:delete()
    obj.actualText:delete()
end
