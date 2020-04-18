local Pasteboard = require("hs.pasteboard")
local UI = require("rb.ui")
local fuzzyChooser = require("rb.fuzzychooser")

local obj = {}

obj.id = "com.apple.iChat"

local function chooserCallback(choice)
  Pasteboard.setContents(choice.text)
  os.execute(string.format([["/usr/bin/open" "%s"]], choice.text))
end

function obj.getLinks(appObj)
  local linkElements =
    UI.getUIElement(
    appObj:mainWindow(),
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
  fuzzyChooser:start(chooserCallback, choices, {"text"})
end

return obj
