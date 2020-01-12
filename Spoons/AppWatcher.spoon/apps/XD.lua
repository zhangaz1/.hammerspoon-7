local hotkey = require("hs.hotkey")
local Util = require("rb.util")

local obj = {}
obj.id = "com.adobe.xd"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

obj.modal:bind(
  {"cmd"},
  "1",
  function()
    Util.strictShortcut(
      {{"cmd"}, "1"},
      obj.thisApp,
      obj.modal,
      nil,
      function()
        obj.thisApp:selectMenuItem({"View", "Assets"})
      end
    )
  end
)
obj.modal:bind(
  {"cmd"},
  "2",
  function()
    Util.strictShortcut(
      {{"cmd"}, "2"},
      obj.thisApp,
      obj.modal,
      nil,
      function()
        obj.thisApp:selectMenuItem({"View", "Layers"})
      end
    )
  end
)
obj.modal:bind(
  {"cmd"},
  "3",
  function()
    Util.strictShortcut(
      {{"cmd"}, "3"},
      obj.thisApp,
      obj.modal,
      nil,
      function()
        obj.thisApp:selectMenuItem({"View", "Plugins"})
      end
    )
  end
)

return obj
