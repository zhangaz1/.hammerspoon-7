local Application = require("hs.application")
local JSON = require("hs.json")
local ax = require("hs._asm.axuielement")
local UI = require("rb.ui")

local obj = {}

function obj.getMailMessageLinks()
  local appObj = Application("com.apple.mail")
  local window = ax.windowElement(appObj:focusedWindow())
  -- when viewed in the main app OR when viewed in a standalone container
  local messageWindow = UI.getUIElement(window, ({{"AXSplitGroup", 1}, {"AXSplitGroup", 1}, {"AXScrollArea", 2}})) or UI.getUIElement(window, ({{"AXScrollArea", 1}}))
  local messageContainers = messageWindow:attributeValue("AXChildren")
  local choices = {}
  for _, messageContainer in ipairs(messageContainers) do
    if messageContainer:attributeValue("AXRole") == "AXGroup" then
      local webArea =
        UI.getUIElement(
        messageContainer,
        {
          {"AXScrollArea", 1},
          {"AXGroup", 1},
          {"AXGroup", 1},
          {"AXScrollArea", 1},
          {"AXWebArea", 1}
        }
      )
      local links = webArea:attributeValue("AXLinkUIElements")
      for _, v in ipairs(links) do
        local title = v:attributeValue("AXTitle")
        local url = v:attributeValue("AXURL")
        table.insert(
          choices,
          {
            url = url,
            title = title or url,
            subtitle = url
          }
        )
      end
    end
  end
  print(JSON.encode(choices))
end

function obj.getChatMessageLinks()
  local appObj = Application("com.apple.iChat")
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
    local url = link:attributeValue("AXChildren")[1]:attributeValue("AXValue")
    table.insert(
      choices,
      {
        title = url,
        url = url,
        subtitle = url
      }
    )
  end
  print(JSON.encode(choices))
end

return obj
