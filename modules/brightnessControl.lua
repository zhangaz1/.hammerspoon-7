local brightness = require("hs.brightness")
local screen = require("hs.screen")
local drawing = require("hs.drawing")
local hotkey = require("hs.hotkey")

local mod = {}

local possibleBrightnessLevels = { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }
local currentScreenFrame = screen.mainScreen():frame()
local currentScreenHorizontalCenter = (currentScreenFrame.w / 2)
local currentScreenVerticalCenter = (currentScreenFrame.h / 2)

local background;
local textObject;

local function getBrightness()
    local currentBrightness = brightness.get()
    for _=1,10 do
        if currentBrightness % 10 == 0 then
            break
        else
            currentBrightness = currentBrightness + 1
        end
    end
    return currentBrightness
end

local function createAndShowBackground()
    background = drawing.rectangle({
        w = 100,
        h = 100,
        x = currentScreenHorizontalCenter - 50,
        y = currentScreenVerticalCenter - 50
    })
        :setRoundedRectRadii(15, 15)
        :setStroke(false)
        :setFillColor(drawing.color.colorsFor("System")["windowBackgroundColor"])
        :bringToFront(true)
        :show()
end

local function displayBrightnessText()
    local currentBrightness = getBrightness()
    if textObject ~= nil and textObject["delete"] then
        textObject:delete()
    end
    local textStyle = {
        font = {
          name = "System Font",
          size = 27
        },
        paragraphStyle = {
          alignment = "center"
        },
        color = drawing.color.colorsFor("System")["secondaryLabelColor"]
      }
    local theText = hs.styledtext.new(currentBrightness, textStyle)
    local textFrame = drawing.getTextDrawingSize(theText)
    textObject = drawing.text({
        w = textFrame.w + 4, -- safety buffer
        h = textFrame.h + 4, -- safety buffer
        x = currentScreenHorizontalCenter - (textFrame.w / 2),
        y = currentScreenVerticalCenter - (textFrame.h / 2)
    }, theText)
        :bringToFront(true)
        :show()
end

local function setBrightness(increaseOrDecrease)
    local newBrightness;
    for i ,v in ipairs(possibleBrightnessLevels) do
        if getBrightness() == v then
            if increaseOrDecrease == "increase" then
                newBrightness = possibleBrightnessLevels[i+1]
            elseif increaseOrDecrease == "decrease" then
                newBrightness = possibleBrightnessLevels[i-1]
            end
            break
        end
    end
    brightness.set(newBrightness)
    displayBrightnessText()
end

local controlModal = hotkey.modal.new()

local function destroyModal()
    controlModal:exit()
    background:delete()
    textObject:delete()
end

controlModal:bind({}, "right", nil, function() setBrightness("increase") end, nil)
controlModal:bind({}, "left", nil, function() setBrightness("decrease") end, nil)
controlModal:bind({}, "escape", nil, function() destroyModal() end, nil, nil)
controlModal:bind({}, "return", nil, function() destroyModal() end, nil, nil)
controlModal:bind({"cmd"}, "w", nil, function() destroyModal() end, nil, nil)

function mod.init()
    createAndShowBackground()
    displayBrightnessText()
    controlModal:enter()
end

return mod
