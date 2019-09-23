local hotkey = require('hs.hotkey')
local ui = require("util.ui")
local ax = require("hs._asm.axuielement")
local eventtap = require("hs.eventtap")

local m = {}
m.id = 'com.latenightsw.ScriptDebugger7'
m.thisApp = nil
m.modal = hotkey.modal.new()

m.uiPane1 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
m.uiPane2 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXScrollArea', 1}, {'AXOutline', 1}}
m.uiPane3 = {{'AXWindow', 1}, {'AXSplitGroup', 1}, {'AXGroup', 1}, {'AXSplitGroup', 1}, {'AXScrollArea', 1}, {'AXWebArea', 1}}

m.modal:bind({'alt'}, '1', function() ui.getUIElement(m.thisApp, m.uiPane1):setAttributeValue('AXFocused', true) end)
m.modal:bind({'alt'}, '2', function() ui.getUIElement(m.thisApp, m.uiPane2):setAttributeValue('AXFocused', true) end)
m.modal:bind({'alt'}, '3', function() ui.getUIElement(m.thisApp, m.uiPane3):setAttributeValue('AXFocused', true) end)

local function textCompletion(options)
	local appObj = options.appObj
	local appObjBundleId = options.appObjBundleId
	local appModal = options.appModal
	local axIdentifier = options.axIdentifier
	local standardExecution = options.standardExecution
	local specialExecution = options.specialExecution

    local trulyFocusedAppIdentifier = hs.window.focusedWindow():application():bundleID()
	local focusedUIElement = ax.applicationElement(appObj):focusedUIElement():attributeValue('AXRole')

	if (focusedUIElement == axIdentifier) and (trulyFocusedAppIdentifier == appObjBundleId) then
		eventtap.keyStroke(table.unpack(specialExecution))
	else
		appModal:exit()
		eventtap.keyStroke(table.unpack(standardExecution))
		appModal:enter()
	end
end

m.modal:bind({"cmd"}, "d", function()
	textCompletion({
		appObj = m.thisApp,
		appObjBundleId = m.id,
		appModal = m.modal,
		axIdentifier = "AXTextArea",
		standardExecution = {{}, "tab"},
		specialExecution = {{}, "escape"},
	})
end)

return m
