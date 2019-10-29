local mod = {}

function mod.strictShortcut(hotkey, fn, exec)
    if fn() then
        print(exec)
    else
        print(hotkey)
    end
end

-- -- TODO: MODULIZE
-- local function textCompletion(options)
-- 	local appObj = options.appObj
-- 	local appObjBundleId = options.appObjBundleId
-- 	local appModal = options.appModal
-- 	local axIdentifier = options.axIdentifier
-- 	local standardExecution = options.standardExecution
-- 	local specialExecution = options.specialExecution

-- 	local trulyFocusedAppIdentifier = window.focusedWindow():application():bundleID()
-- 	local focusedUIElement = ax.applicationElement(appObj):focusedUIElement():attributeValue('AXRole')

-- 	if (focusedUIElement == axIdentifier) and (trulyFocusedAppIdentifier == appObjBundleId) then
-- 		eventtap.keyStroke(table.unpack(specialExecution))
-- 	else
-- 		appModal:exit()
-- 		eventtap.keyStroke(table.unpack(standardExecution))
-- 		appModal:enter()
-- 	end
-- end
-- m.modal:bind({"cmd"}, "d", function()
-- 	textCompletion({
-- 		appObj = m.thisApp,
-- 		appObjBundleId = m.id,
-- 		appModal = m.modal,
-- 		axIdentifier = "AXTextArea",
-- 		standardExecution = {{}, "tab"},
-- 		specialExecution = {{}, "escape"},
-- 	})
-- end)

return mod
