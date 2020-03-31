local function keyStroke(keys)
  hs.eventtap.keyStroke(keys[1], keys[2])
end

enabled = nil
hotkeys = {}

local function enable()
  enabled = true
  for _, v in ipairs(normalMode) do
    local from = v.from
    local hk =
      hs.hotkey.bind(
      from[1], from[2],
      function()
        keyStroke(v.to)
      end
    )
    table.insert(hotkeys, hk)
  end
end

local function disable()
  enabled = false
  for _, v in ipairs(hotkeys) do
    v:disable()
  end
end

local function toggle()
  if enabled then
    disable()
  else
    enable()
  end
end

local hyper = {"shift", "cmd", "alt", "ctrl"}
hs.hotkey.bind(
  hyper,
  "u",
  function()
    toggle()
  end
)
