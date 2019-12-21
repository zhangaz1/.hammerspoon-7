local hotkey = require("hs.hotkey")
local strictShortcut = require("util.strictShortcut")

local obj = {}
obj.id = "com.adobe.xd"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

obj.modal:bind(
  {"cmd"},
  "1",
  function()
    strictShortcut.perform(
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
    strictShortcut.perform(
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
    strictShortcut.perform(
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
