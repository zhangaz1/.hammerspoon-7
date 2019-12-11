local hotkey = require('hs.hotkey')
local ax = require("hs._asm.axuielement")
local ui = require("util.ui")

local m = {}

m.id = "com.kapeli.dashdoc"
m.thisApp = nil
m.modal = hotkey.modal.new()

-- the upper table as a documentation browser
local docsBrowser = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
-- if the upper table is a documentation browser, the lower table (if any) becomes the table of contents. else,
-- the upper table is a list of search resulsts, and the lower table (if any) becomes the table of contents.
local searchResultsOrPageToc = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXTable', 1}}
-- if the upper table is a list of search resulsts, the lower table (if any) becomes the table of contents.
local pageToc = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 2}, {'AXTable', 1}}
-- the actual documentation viewer
local docViewer = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {"AXSplitGroup", 2}, {"AXScrollArea", 1}, {"AXWebArea", 1}}

local function pane1()
    local selectedElement = ax.applicationElement(m.thisApp):focusedUIElement()
    local db = ui.getUIElement(m.thisApp, docsBrowser)
    local sropt = ui.getUIElement(m.thisApp, searchResultsOrPageToc)
    local upper;
    local lower;
    if db then
        upper = db
        lower = ui.getUIElement(m.thisApp, searchResultsOrPageToc)
    elseif sropt then
        upper = sropt
        lower = ui.getUIElement(m.thisApp, pageToc)
    end
    if selectedElement == upper then
        lower:setAttributeValue('AXFocused', true)
    elseif selectedElement == lower then
        upper:setAttributeValue('AXFocused', true)
    else
        upper:setAttributeValue('AXFocused', true)
    end
end

local function pane2()
    ui.getUIElement(m.thisApp, docViewer):setAttributeValue('AXFocused', true)
end

local function pane3()
    ui.getUIElement(m.thisApp, docViewer):setAttributeValue('AXFocused', true)
end

m.modal:bind({'alt'}, '1', function() pane1() end)
m.modal:bind({'alt'}, '2', function() pane2() end)
m.modal:bind({'alt'}, '3', function() pane3() end)

return m
