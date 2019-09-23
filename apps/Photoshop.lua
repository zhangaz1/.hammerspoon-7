-- local application = require('hs.application')
-- local hotkey = require('hs.hotkey')

local mod = {}

mod.id = 'com.adobe.Photoshop'
-- m.thisApp = application.applicationsForBundleID(m.id)[1]
-- function mod.thisApp() return application.applicationsForBundleID(m.id)[1] end
-- m.modal = hotkey.modal.new()

-- Photoshop.autoAdjustments = function()
--     for _,menuitem in ipairs({{'Image', 'Auto Tone'}, {'Image', 'Auto Color'}, {'Image', 'Auto Contrast'}}) do
--         currentAppObj:selectMenuItem(menuitem)
--     end
-- end

-- m.appScripts = {
--   { title = "Auto Adjustments", func = function() Photoshop.autoAdjustments() end }
-- }

return mod
