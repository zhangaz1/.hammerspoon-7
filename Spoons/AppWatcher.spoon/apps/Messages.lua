local hotkey = require("hs.hotkey")
local UI = require("util.ui")
local Chooser = require("util.FuzzyChooser")

local obj = {}
obj.id = "com.apple.iChat"
obj.thisApp = nil
obj.modal = hotkey.modal.new()

local function chooserCallback(choice)
  os.execute(string.format([["/usr/bin/open" "%s"]], choice.text))
end

local function getLinks()
  local linkElements =
    UI.getUIElement(
    obj.thisApp:mainWindow(),
    {
      {"AXSplitGroup", 1},
      {"AXScrollArea", 2},
      {"AXWebArea", 1}
    }
  ):attributeValue("AXLinkUIElements")
  local choices = {}
  for _, link in ipairs(linkElements) do
    local text = link:attributeValue("AXChildren")[1]:attributeValue("AXValue")
    table.insert(
      choices,
      {
        text = text
      }
    )
  end
  Chooser.start(chooserCallback, choices, {"text"})
end

obj.modal:bind(
  {"alt"},
  "o",
  function()
    getLinks()
  end
)

return obj