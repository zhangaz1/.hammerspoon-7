local obj = {}
-- local Util = require("rb.util")

function obj._(t)
  local n = 0
  for _, _ in pairs(t) do
    n = n + 1
  end
  return n
end

return obj
