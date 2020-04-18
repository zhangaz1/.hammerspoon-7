local obj = {}

obj.current = nil

local function normalMode()
  obj.current = "normal"
end

local function insertMode()
  obj.current = "insert"
end

local function toggle()
  if obj.current == "normal" then
    insertMode()
  else
    normalMode()
  end
end

return obj
