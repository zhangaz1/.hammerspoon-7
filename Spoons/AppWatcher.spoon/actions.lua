local spoon = spoon

local function getAppEnv(app)
  return spoon.AppWatcher.appFunctions[app]
end

local function getFrontApp()
  return spoon.AppWatcher.frontApp
end

local obj = {
  ["com.agilebits.onepassword7"] = {
    ["Convert to Login"] = function() getAppEnv("com.agilebits.onepassword7").convertToLogin() end,
    ["Sort By"] = function() getAppEnv("com.agilebits.onepassword7").sortBy(getFrontApp()) end,
    ["Toggle Categories"] = function() getAppEnv("com.agilebits.onepassword7").toggleCategories(getFrontApp(), "CATEGORIES") end,
    ["Toggle Tags"] = function() getAppEnv("com.agilebits.onepassword7").toggleCategories(getFrontApp(), "TAGS") end,
    ["Toggle Watchtower"] = function() getAppEnv("com.agilebits.onepassword7").toggleCategories(getFrontApp(), "WATCHTOWER") end,
  },
  ["com.apple.finder"] = {
    ["Deselect All"] = function() getAppEnv("com.apple.finder").deselectAll() end,
    ["Dropbox Smart Sync: Local"] = function() getAppEnv("com.apple.finder").dropboxSmartSyncToggle("Local") end,
    ["Dropbox Smart Sync: Online Only"] = function() getAppEnv("com.apple.finder").dropboxSmartSyncToggle("Online Only") end,
    ["Duplicate Tab"] = function() getAppEnv("com.apple.finder").duplicateTab() end,
    ["Go Back"] = function() getAppEnv("com.apple.finder").clickHistoryToolbarItem(getFrontApp(), "back") end,
    ["Go Forward"] = function() getAppEnv("com.apple.finder").clickHistoryToolbarItem(getFrontApp(), "forward") end,
    ["Invert Selection"] = function() getAppEnv("com.apple.finder").invertSelection() end,
    ["Next Search Scope"] = function() getAppEnv("com.apple.finder").nextSearchScope() end,
    ["Toggle Columns"] = function() getAppEnv("com.apple.finder").toggleColumns() end,
    ["Toggle Sort Direction"] = function() getAppEnv("com.apple.finder").toggleSortingDirection() end,
    ["Traverse Up"] = function() getAppEnv("com.apple.finder").traverseUp() end,
  },
  ["com.adobe.illustrator"] = {
    ["Export Artboards as PDFs to Desktop"] = function() getAppEnv("com.adobe.illustrator").exportAs("pdf") end,
    ["Export Artboards as PNGs to Desktop"] = function() getAppEnv("com.adobe.illustrator").exportAs("png") end,
    ["Export Artboards as SVGs to Desktop"] = function() getAppEnv("com.adobe.illustrator").exportAs("svg") end,
  },
  ["com.adobe.InDesign"] = {
    ["Export as as PNG to Desktop"] = function() getAppEnv("com.adobe.InDesign").exportAsPNG() end,
    ["Export as High Quality PDF to Desktop"] = function() getAppEnv("com.adobe.InDesign").exportAsPDF() end,
  },
  ["com.apple.mail"] = {
    ["Copy Sender's Addresss"] = function() getAppEnv("com.apple.mail").copySenderAddres() end,
  },
  ["com.apple.Notes"] = {
    ["Left to Right Writing Direction"] = function() getAppEnv("com.apple.Notes").writingDirection("Left to Right") end,
    ["Right to Left Writing Direction"] = function() getAppEnv("com.apple.Notes").writingDirection("Right to Left") end
  },
  ["com.apple.iWork.Pages"] = {
    ["Font Family"] = function() getAppEnv("com.apple.iWork.Pages").fontFamily() end,
    ["Paragraph Style"] = function() getAppEnv("com.apple.iWork.Pages").paragraphStyle() end,
  },
  ["com.adobe.Photoshop"] = {
    ["Auto Adjustments"] = function() getAppEnv("com.adobe.Photoshop").autoAdjustments(getFrontApp()) end
  },
  ["com.apple.Preview"] = {
    ["Go to First Page"] = function() getAppEnv("com.apple.Preview").goToFirstPage() end,
    ["Go to Last Page"] = function() getAppEnv("com.apple.Preview").goToLastPage() end
  },
  ["com.apple.systempreferences"] = {
    ["Authorize Pane"] = function() getAppEnv("com.apple.systempreferences").authorizePane() end,
    ["Allow/Enable..."] = function() getAppEnv("com.apple.systempreferences").allowAnyway() end,
  },
  ["desktop.WhatsApp"] = {
    ["Insert GIF"] = function() getAppEnv("desktop.WhatsApp").insertGif() end,
    ["Attach File"] = function() getAppEnv("desktop.WhatsApp").whatsAppMouseScripts(getFrontApp(), "AttachFile") end,
    ["Use Here"] = function() getAppEnv("desktop.WhatsApp").whatsAppMouseScripts(getFrontApp(), "Use Here") end
  },
  ["com.apple.Safari"] = {
    ["Close Tabs to the Left"] = function() getAppEnv("com.apple.Safari").closeTabsToDirection("left") end,
    ["Close Tabs to the Right"] = function() getAppEnv("com.apple.Safari").closeTabsToDirection("right") end,
    ["Duplicate Tab"] = function() getAppEnv("com.apple.Safari").duplicateTab() end,
    ["New Invoice for Current iCount Customer"] = function() getAppEnv("com.apple.Safari").newInvoiceForCurrentIcountCustomer() end,
    ["Open This Tab in Chrome"] = function() getAppEnv("com.apple.Safari").openThisTabInChrome() end,
    ["Save Page as PDF"] = function() getAppEnv("com.apple.Safari").savePageAsPDF() end,
    ["Translate"] = function() getAppEnv("com.apple.Safari").clickOnTranslateMeMenuButton() end,
    ["Open as Private Tab"] = function() getAppEnv("com.apple.Safari").openAsPrivateTab() end,
  }
}

return obj
