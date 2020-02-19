local ax = require("hs._asm.axuielement")
local ui = require("rb.ui")

local obj = {
  id = "com.apple.ActivityMonitor",
  clickActivityMonitorRadioButton = function (appObj, aButton)
    ui.getUIElement(
      ax.windowElement(appObj:mainWindow()),
      {
        {"AXToolbar", 1},
        {"AXGroup", 2},
        {"AXRadioGroup", 1},
        {"AXRadioButton", tonumber(aButton)}
      }
    ):performAction("AXPress")
  end
}

return obj
