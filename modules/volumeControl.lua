local audiodevice = require("hs.audiodevice")
local screen = require("hs.screen")
local drawing = require("hs.drawing")
local hotkey = require("hs.hotkey")

local mod = {}

-- VARIABLES
local textObject;
local background;


-- CONSTANTS
local possibleVolumes = { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }
local audio_dev = audiodevice.defaultOutputDevice()
-- screen dimensions used to align the drawing objects
local currentScreenFrame = screen.mainScreen():frame()
local currentScreenHorizontalCenter = (currentScreenFrame.w / 2)
local currentScreenVerticalCenter = (currentScreenFrame.h / 2)


local function getVolume()
    local currentVolume = audio_dev:volume()
    local currentVolumeRoundedUp = math.ceil(currentVolume)
    for _ = 1,10 do
        if (currentVolumeRoundedUp % 10 == 0) then
            break
        else
            currentVolumeRoundedUp = currentVolumeRoundedUp - 1
        end
    end
    return currentVolumeRoundedUp
end


local function displayVolume()
    local currVol = getVolume()
    if textObject then
        textObject:delete()
    end
    local textStyle = { size = 30, alignment = "center", color = drawing.color.colorsFor("System")["labelColor"] }
    local textFrame = drawing.getTextDrawingSize(currVol, textStyle)
    textObject = drawing.text({
        w = textFrame.w + 4, -- safety buffer
        h = textFrame.h + 4, -- safety buffer
        x = currentScreenHorizontalCenter - (textFrame.w / 2),
        y = currentScreenVerticalCenter - (textFrame.h / 2)
    }, currVol)
        :bringToFront(true)
        :show()
end


local function updateVolume(increaseOrDecrease)
    local newVolume
    for i,v in ipairs(possibleVolumes) do
        if v == getVolume() then
            if increaseOrDecrease == "increase" then
                if v == 100 then return end
                newVolume = possibleVolumes[i+1]
            elseif increaseOrDecrease == "decrease" then
                if v == 0 then return end
                newVolume = possibleVolumes[i-1]
            end
        end
    end
    audio_dev:setVolume(newVolume)
    displayVolume()
end


function mod.setVolume(level)
    audio_dev:setVolume(level)
    displayVolume()
end


function mod.init()
    if audio_dev:muted() then
        audio_dev:setMuted(false)
    end
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
    displayVolume()
    mod.volumeControlModal:enter()
end


local function destroyModal()
    mod.volumeControlModal:exit()
    background:delete()
    textObject:delete()
end


mod.volumeControlModal = hotkey.modal.new()
mod.volumeControlModal:bind({}, "right", nil, function() updateVolume("increase") end, function() updateVolume("increase") end, nil)
mod.volumeControlModal:bind({}, "left", nil, function() updateVolume("decrease") end, function() updateVolume("decrease") end, nil)
mod.volumeControlModal:bind({"cmd"}, "right", nil, function() mod.setVolume(100) end)
mod.volumeControlModal:bind({"cmd"}, "left", nil, function() mod.setVolume(0) end)
mod.volumeControlModal:bind({}, "escape", nil, function() destroyModal() end, nil, nil)
mod.volumeControlModal:bind({'cmd'}, "w", nil, function() destroyModal() end, nil, nil)
mod.volumeControlModal:bind({'cmd'}, "q", nil, function() destroyModal() end, nil, nil)
mod.volumeControlModal:bind({'cmd'}, "h", nil, function() destroyModal() end, nil, nil)
-- mod.volumeControlModal:bind({'cmd'}, "tab", nil, function() destroyModal() end, nil, nil)
mod.volumeControlModal:bind({}, "return", nil, function() destroyModal() end, nil, nil)

return mod

--[[
local function fancyVolumeDisplay()
    -- local audio_dev = audiodevice.defaultOutputDevice()
    -- local currentVolume = (audio_dev:volume())
    -- local currentVolumeRoundedDown = math.floor(currentVolume)

    -- for _=1,10 do
    --     if (currentVolumeRoundedDown % 10 == 0) then
    --         print(currentVolumeRoundedDown)
    --         break
    --     else
    --         currentVolumeRoundedDown = currentVolumeRoundedDown - 1
    --     end
    -- end

    -- getting the screen
    local currentScreenFrame = screen.mainScreen():frame()
    local currentScreenHorizontalCenter = (currentScreenFrame.w / 2)
    local currentScreenVerticalCenter = (currentScreenFrame.h / 2)
    -- single volume bar dimensions
    local singleBarWidth = 10
    local singleBarHeight = 20
    local separatingSpaceWidth = 2
    -- a table to 'store' the bars
    local volumeBars = {}
    -- all volume bars combined dimensions
    local volumeBarWidth = (singleBarWidth * 10) + (separatingSpaceWidth * 10)
    local volumeBarHorizontalCenter = (volumeBarWidth / 2)
    local volumeBarVerticalCenter = (singleBarHeight / 2)
    -- aligned coords of the volume bar
    local alignedXForVolumeBar = currentScreenHorizontalCenter - volumeBarHorizontalCenter
    local alignedYForVolumeBar = currentScreenVerticalCenter - volumeBarVerticalCenter
    -- the background
    local backgroundWidth = volumeBarWidth + 40
    local backgroundHeight = singleBarHeight + 40
    local backgroundWidthHorizontalCenter = (backgroundWidth / 2)
    local backgroundHeightVerticalCenter = (backgroundHeight / 2)
    local alignedXForBackground = currentScreenHorizontalCenter - backgroundWidthHorizontalCenter
    local alignedYForBackground = currentScreenVerticalCenter - backgroundHeightVerticalCenter

    local background = drawing.rectangle({
        w = backgroundWidth,
        h = backgroundHeight,
        x = alignedXForBackground,
        y = alignedYForBackground
    })
        :setStroke(false)
        :setFillColor({hex = "#3a3a3c", alpha = "1.0"})
        :show()

    local n = 0
    for _=1,10 do
        local bar = drawing.rectangle({
            w = singleBarWidth,
            h = singleBarHeight,
            x = alignedXForVolumeBar + n,
            y = alignedYForVolumeBar})
            :setStroke(false)
            :show()
        table.insert( volumeBars, bar )
        n = n + singleBarWidth + separatingSpaceWidth
    end
    timer.doAfter(5, function()
        for _,v in ipairs(volumeBars) do
            v:hide()
        end
        background:hide()
    end)
end
 ]]
