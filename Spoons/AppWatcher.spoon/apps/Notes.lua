local hotkey = require("hs.hotkey")
local osascript = require("hs.osascript")

local ui = require("rb.ui")

local m = {}

m.id = "com.apple.Notes"
m.thisApp = nil
m.modal = hotkey.modal.new()

local function writingDirection(direction)
    osascript.applescript([[
        tell application "System Events"
            tell application process "Notes"
                tell menu bar 1
                    tell menu bar item "Format"
                        tell menu 1
                            tell menu item "Text"
                                tell menu 1
                                    tell menu item "Writing Direction"
                                        tell menu 1
                                            click (every menu item whose title contains "]] .. direction .. [[")
                                        end tell
                                    end tell
                                end tell
                            end tell
                        end tell
                    end tell
                end tell
            end tell
        end tell
    ]])
end

local function pane1()
    ui.getUIElement(
        m.thisApp,
        {
            {"AXWindow", 1},
            {"AXSplitGroup", 1},
            {"AXScrollArea", 1},
            {"AXOutline", 1}
        }
    ):setAttributeValue("AXFocused", true)
end

local function pane2()
    ui.getUIElement(
        m.thisApp,
        {
            {"AXWindow", 1},
            {"AXSplitGroup", 1},
            {"AXSplitGroup", 1},
            {"AXScrollArea", 1}
        }
    ):setAttributeValue("AXFocused", true)
end

local function pane3()
    ui.getUIElement(
        m.thisApp,
        {
            -- text area 1 of scroll area 1 of group 1 of splitter group 1 of splitter group 1 of window "Notes"  of application process "Notes"
            {"AXWindow", 1},
            {"AXSplitGroup", 1},
            {"AXSplitGroup", 1},
            {"AXGroup", 1},
            {"AXScrollArea", 1},
            {"AXTextArea", 1}
        }
    ):setAttributeValue("AXFocused", true)
end

m.modal:bind(
    {"alt"},
    "1",
    function()
        pane1()
    end
)
m.modal:bind(
    {"alt"},
    "2",
    function()
        pane2()
    end
)
m.modal:bind(
    {"alt"},
    "3",
    function()
        pane3()
    end
)

m.appScripts = {
    {
        title = "Left to Right Writing Direction",
        func = function()
            writingDirection("Left to Right")
        end
    },
    {
        title = "Right to Left Writing Direction",
        func = function()
            writingDirection("Right to Left")
        end
    }
}

return m
