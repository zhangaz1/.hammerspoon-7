local hotkey = require("hs.hotkey")

local mod = {}

mod.id = "com.adobe.Photoshop"
mod.thisApp = nil
mod.modal = hotkey.modal.new()

local function autoAdjustments()
  for _, menuitem in ipairs({{"Image", "Auto Tone"}, {"Image", "Auto Color"}, {"Image", "Auto Contrast"}}) do
    mod.thisApp:selectMenuItem(menuitem)
  end
end

mod.appScripts = {
  {title = "Auto Adjustments", func = function()
      autoAdjustments()
    end}
}

return mod
