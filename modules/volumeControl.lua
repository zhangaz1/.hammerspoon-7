local audiodevice = require("hs.audiodevice")
local screen = require("hs.screen")
local drawing = require("hs.drawing")
local hotkey = require("hs.hotkey")
local styledtext = require("hs.styledtext")

local mod = {}

-- VARIABLES
local textObject;
local background;

-- CONSTANTS
local possibleVolumes = { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }

mod.volumeControlModal = hotkey.modal.new()
mod.volumeControlModal:bind({}, "right", nil, function() mod.updateVolume("increase") end, function() mod.updateVolume("increase") end, nil)
mod.volumeControlModal:bind({}, "left", nil, function() mod.updateVolume("decrease") end, function() mod.updateVolume("decrease") end, nil)
mod.volumeControlModal:bind({"alt"}, "right", nil, function() mod.setCurrentVolume(100) end)
mod.volumeControlModal:bind({"alt"}, "left", nil, function() mod.setCurrentVolume(0) end)
mod.volumeControlModal:bind({"cmd"}, "right", nil, function() mod.setCurrentVolume(100) end)
mod.volumeControlModal:bind({"cmd"}, "left", nil, function() mod.setCurrentVolume(0) end)
mod.volumeControlModal:bind({}, "escape", nil, function() mod.destroyModal() end, nil, nil)
mod.volumeControlModal:bind({'cmd'}, "w", nil, function() mod.destroyModal() end, nil, nil)
mod.volumeControlModal:bind({'cmd'}, "q", nil, function() mod.destroyModal() end, nil, nil)
mod.volumeControlModal:bind({'cmd'}, "h", nil, function() mod.destroyModal() end, nil, nil)
mod.volumeControlModal:bind({}, "return", nil, function() mod.destroyModal() end, nil, nil)

function mod.currentAudioDevice()
  local audio_dev = audiodevice.defaultOutputDevice()
  if audio_dev:muted() then
    audio_dev:setMuted(false)
  end
  return audio_dev
end

-- screen dimensions used to align the drawing objects
local currentScreenFrame = screen.mainScreen():frame()
local currentScreenHorizontalCenter = (currentScreenFrame.w / 2)
local currentScreenVerticalCenter = (currentScreenFrame.h / 2)

function mod.init()
  mod.currentAudioDevice()
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
  mod.displayTextForCurrentVolume()
  mod.volumeControlModal:enter()
end

function mod.destroyModal()
  mod.volumeControlModal:exit()
  background:delete()
  textObject:delete()
end

function mod.getCurrentVolume()
  local currentVolume = mod.currentAudioDevice():volume()
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

function mod.setCurrentVolume(level)
  mod.currentAudioDevice():setVolume(level)
  mod.displayTextForCurrentVolume()
end

function mod.displayTextForCurrentVolume()
  local currVol = tostring(mod.getCurrentVolume())
  if textObject ~= nil and textObject["delete"] then
    -- print(hs.inspect(textObject))
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
  local styledText = styledtext.new(currVol, textStyle)
  local textFrame = drawing.getTextDrawingSize(styledText)
  textObject = drawing.text({
    w = textFrame.w + 4, -- safety buffer
    h = textFrame.h + 4, -- safety buffer
    x = currentScreenHorizontalCenter - (textFrame.w / 2),
    y = currentScreenVerticalCenter - (textFrame.h / 2)
  }, styledText)
    :bringToFront(true)
    :show()
end

function mod.updateVolume(increaseOrDecrease)
  local newVolume
  for i,v in ipairs(possibleVolumes) do
    if v == mod.getCurrentVolume() then
      if increaseOrDecrease == "increase" then
        if v == 100 then return end
        newVolume = possibleVolumes[i+1]
      elseif increaseOrDecrease == "decrease" then
        if v == 0 then return end
        newVolume = possibleVolumes[i-1]
      end
    end
  end
  mod.currentAudioDevice():setVolume(newVolume)
  mod.displayTextForCurrentVolume()
end

return mod
