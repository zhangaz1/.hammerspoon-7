local Window = require("hs.window")
local Geometry = require("hs.geometry")
local Hotkey = require("hs.hotkey")
local Screen = require("hs.screen")
local Drawing = require("hs.drawing")
local Webview = require("hs.webview")
local util = require("rb.util")

local obj = {}

obj.__index = obj
obj.name = "WindowManagerModal"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.windowManagerModal = nil
obj.cheatSheet = nil

local function move(direction)
  local point
  if direction == "right" then
    point = {60, 0}
  elseif direction == "left" then
    point = {-60, 0}
  elseif direction == "up" then
    point = {0, -60}
  elseif direction == "down" then
    point = {0, 60}
  end
  Window.focusedWindow():move(point)
end

local function resize(resizeKind)
  local rect
  local currentFrame = Window.focusedWindow():frame()
  local x = currentFrame._x
  local y = currentFrame._y
  local w = currentFrame._w
  local h = currentFrame._h
  if resizeKind == "growToTop" then
    rect = {x = x, y = y - 30, w = w, h = h + 30}
  elseif resizeKind == "growToRight" then
    rect = {x = x, y = y, w = w + 30, h = h}
  elseif resizeKind == "growToBottom" then
    rect = {x = x, y = y, w = w, h = h + 30}
  elseif resizeKind == "growToLeft" then
    rect = {x = x - 30, y = y, w = w + 30, h = h}
  elseif resizeKind == "shrinkFromTop" then
    rect = {x = x, y = y + 30, w = w, h = h - 30}
  elseif resizeKind == "shrinkFromBottom" then
    rect = {x = x, y = y, w = w, h = h - 30}
  elseif resizeKind == "shrinkFromRight" then
    rect = {x = x, y = y, w = w - 30, h = h}
  elseif resizeKind == "shrinkFromLeft" then
    rect = {x = x + 30, y = y, w = w - 30, h = h}
  end
  Window.focusedWindow():setFrame(Geometry.rect(rect))
end

local modalHotkeys = {
  {shortcut = {modifiers = {}, key = "up"}, pressedfn = move, repeatfn = move, arg = "up", txt = "Move Up"},
  {shortcut = {modifiers = {}, key = "down"}, pressedfn = move, repeatfn = move, arg = "down", txt = "Move Down"},
  {shortcut = {modifiers = {}, key = "left"}, pressedfn = move, repeatfn = move, arg = "left", txt = "Move Left"},
  {shortcut = {modifiers = {}, key = "right"}, pressedfn = move, repeatfn = move, arg = "right", txt = "Move Right"},
  {
    shortcut = {modifiers = {"alt"}, key = "left"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "shrinkFromRight",
    txt = "Shrink from Right"
  },
  {
    shortcut = {modifiers = {"alt"}, key = "right"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "shrinkFromLeft",
    txt = "Shrink from Left"
  },
  {
    shortcut = {modifiers = {"alt"}, key = "up"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "shrinkFromBottom",
    txt = "Shrink from Bottom"
  },
  {
    shortcut = {modifiers = {"alt"}, key = "down"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "shrinkFromTop",
    txt = "Shrink from Top"
  },
  {
    shortcut = {modifiers = {"cmd"}, key = "right"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "growToRight",
    txt = "Grow to Right"
  },
  {
    shortcut = {modifiers = {"cmd"}, key = "left"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "growToLeft",
    txt = "Grow to Left"
  },
  {
    shortcut = {modifiers = {"cmd"}, key = "down"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "growToBottom",
    txt = "Grow to Bottom"
  },
  {
    shortcut = {modifiers = {"cmd"}, key = "up"},
    pressedfn = resize,
    repeatfn = resize,
    arg = "growToTop",
    txt = "Grow to Top"
  }
}

local glyps = {alt = "⌥", ctrl = "⌃", cmd = "⌘", left = "←", right = "→", down = "↓", up = "↑"}

local function createCheatSheet()
  local cheatSheetContents = ""
  -- build the cheatsheet
  for _, keyDescription in ipairs(modalHotkeys) do
    local shortcut = keyDescription.shortcut
    local shortcutString = ""
    for _, modifier in ipairs(shortcut.modifiers) do
      shortcutString = shortcutString .. glyps[modifier]
    end
    shortcutString = shortcutString .. glyps[shortcut.key]
    local action = keyDescription.txt
    local row =
      string.format(
      [[
        <tr>
            <td class="glyphs">%s</td>
            <td class="description">%s</td>
        </tr>
    ]],
      shortcutString,
      action
    )
    cheatSheetContents = cheatSheetContents .. "\n" .. row
  end
  -- format the html
  local function toRGBA(t)
    return string.format([[rgba(%s, %s, %s, %s)]], t.red, t.green, t.blue, t.alpha)
  end
  local cheatSheetBackgroundColor = Drawing.color.lists()["System"]["windowBackgroundColor"]
  local cheatSheetTextColor = Drawing.color.lists()["System"]["labelColor"]

  local html =
    string.format(
    [[
  <!DOCTYPE html>
  <html>
    <head>
    <style type="text/css">
      html, body {
        background-color: %s;
        color: %s;
        font-family: -apple-system, sans-serif;
        font-size: 12px;
      }
      td {
      }
      table {
        padding-top: 24px;
        padding-bottom: 24px;
        padding-left: 24px;
        padding-right: 24px;
      }
      .glyphs {
        text-align: left;
        padding-right: 16px;
        font-weight: bolder;
      }
      .description {
        text-align: right;
        padding-left: 16px;
      }
    </style>
    </head>
    <body>
      <table>%s</table>
    </body>
  </html>
  ]],
    util.winBackgroundColor(),
    util.labelColor(),
    cheatSheetContents
  )
  local screenFrame = Screen.mainScreen():frame()
  local screenWidth = screenFrame.w
  local screenHeight = screenFrame.h
  local modalWidth = screenFrame.w / 7
  local modalHeight = screenFrame.h / 3
  obj.cheatSheet =
    Webview.new(
    {
      x = (screenWidth - modalWidth) - 24,
      y = (screenHeight - modalHeight) - 24,
      w = modalWidth,
      h = modalHeight
    }
  )
  obj.cheatSheet:windowStyle({"titled", "nonactivating", "utility"})
  -- obj.cheatSheet:darkMode(true)
  -- obj.cheatSheet:transparent(true)
  obj.cheatSheet:shadow(true)
  obj.cheatSheet:windowTitle("Window Manager")
  obj.cheatSheet:html(html)
  obj.cheatSheet:level(Drawing.windowLevels._MaximumWindowLevelKey)
  obj.cheatSheet:show()
end

function obj:start()
  obj.windowManagerModal:enter()
  createCheatSheet()
end

function obj:stop()
  obj.windowManagerModal:exit()
  obj.cheatSheet:delete()
end

function obj:init()
  obj.windowManagerModal = Hotkey.modal.new()
  for _, binding in ipairs(modalHotkeys) do
    local arg = binding.arg
    obj.windowManagerModal:bind(
      binding.shortcut.modifiers,
      binding.shortcut.key,
      function()
        binding.pressedfn(arg)
      end,
      nil,
      function()
        binding.repeatfn(arg)
      end
    )
  end
  obj.windowManagerModal:bind({}, "escape", obj.stop)
  obj.windowManagerModal:bind({}, "return", obj.stop)
  obj.windowManagerModal:bind({"cmd", "alt", "ctrl", "shift"}, "w", obj.stop)
end

return obj
