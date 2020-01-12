local Host = require("hs.host")
local Plist = require("hs.plist")
local Geometry = require("hs.geometry")
local Eventtap = require("hs.eventtap")
local Timer = require("hs.timer")
local Window = require("hs.window")
local OSAScript = require("hs.osascript")
local FNUtils = require("hs.fnutils")
local Application = require("hs.application")

local UI = require("rb.ui")
local AX = require("hs._asm.axuielement")

local next = next

local obj = {}

local cloudSettingsPlistFile = "settings/cloudSettings.plist"

function obj.labelColor()
  if Host.interfaceStyle() == "Dark" then
    return "#FFFFFF"
  else
    return "#000000"
  end
end

function obj.winBackgroundColor()
  if Host.interfaceStyle() == "Dark" then
    return "#262626"
  else
    return "#E7E7E7"
  end
end

function obj.doubleLeftClick(coords, mods)
  local point = Geometry.point(coords)
  if mods == nil then
    mods = {}
  end
  local clickState = Eventtap.event.properties.mouseEventClickState
  Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 1):setFlags(mods):post()
  Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 1):setFlags(mods):post()
  Timer.doAfter(
    0.1,
    function()
      Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 2):setFlags(mods):post()
      Eventtap.event.newMouseEvent(Eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 2):setFlags(mods):post()
    end
  )
end

function obj.strictShortcut(keyBinding, app, modal, conditionalFunction, successFunction)
  if (app:bundleID() == Window.focusedWindow():application():bundleID()) then
    local perform = true
    if conditionalFunction ~= nil then
      if not conditionalFunction() then
        perform = false
      end
    end
    if perform then
      successFunction()
    end
  else
    modal:exit()
    Eventtap.keyStroke(table.unpack(keyBinding))
    modal:enter()
  end
end

function obj.getFinderSelection()
  local _, selection, _ = OSAScript.applescript([[
    set theSelectionPOSIX to {}
    tell application "Finder" to set theSelection to selection as alias list
    repeat with i from 1 to count theSelection
      set end of theSelectionPOSIX to (POSIX path of item i of theSelection)
    end repeat
    set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {linefeed}}
    return theSelectionPOSIX as text
    set AppleScript's text item delimiters to saveTID
  ]])
  if not selection then
    return
  end
  selection = FNUtils.split(selection, "\n")
  if next(selection) == nil then
    return nil
  else
    return selection
  end
end

function obj.selectionCount()
  local selection = obj.getFinderSelection()
  if not selection then
    return 0
  end
  local n = 0
  for i, _ in ipairs(selection) do
    n = i
  end
  return n
end

function obj.isSafariAddressBarFocused(appObj)
  local axAppObj = AX.applicationElement(appObj)
  local addressBarObject = UI.getUIElement(axAppObj, {{"AXWindow", "AXMain", true}, {"AXToolbar", 1}}):attributeValue("AXChildren")
  for _, toolbarObject in ipairs(addressBarObject) do
    local toolbarObjectsChilds = toolbarObject:attributeValue("AXChildren")
    if toolbarObjectsChilds then
      for _, toolbarObjectChild in ipairs(toolbarObjectsChilds) do
        if toolbarObjectChild:attributeValue("AXRole") == "AXTextField" then
          return (toolbarObjectChild:attributeValue("AXFocused") == true)
        end
      end
    end
  end
end

function obj.moveFocusToSafariMainArea(appObj, includeSidebar)
  -- the statusbar overlay is AXWindow 1!
  -- pane1 = is either the main web area, or the sidebar
  local UIElementSidebar = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
  local UIElementPane1StandardView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXWebArea", 1}}
  local UIElementPane1BookmarksHistoryView = {{"AXWindow", "AXRoleDescription", "standard window"}, {"AXSplitGroup", 1}, {"AXTabGroup", 1}, {"AXGroup", 1}, {"AXScrollArea", 1}, {"AXOutline", 1}}
  local targetPane
  local sideBar
  local webArea = UI.getUIElement(appObj, UIElementPane1StandardView)
  local bookmarksOrHistory = UI.getUIElement(appObj, UIElementPane1BookmarksHistoryView)
  if includeSidebar then
    sideBar = UI.getUIElement(appObj, UIElementSidebar)
  else
    sideBar = nil
  end
  if sideBar then
    targetPane = sideBar
  elseif webArea then
    targetPane = webArea
  elseif bookmarksOrHistory then
    targetPane = bookmarksOrHistory
  end
  return targetPane:setAttributeValue("AXFocused", true)
end

obj.cloudSettings = {
  get = function(key)
    local rootObject = Plist.read(cloudSettingsPlistFile)
    return rootObject[key]
  end,
  set = function(key, value)
    local rootObject = Plist.read(cloudSettingsPlistFile)
    rootObject[key] = value
    Plist.write(cloudSettingsPlistFile, rootObject)
  end
}

function obj.isFilesAreaFocused(finderAppObj)
  local focusedWindow = finderAppObj:focusedWindow()
  if not focusedWindow then
    return
  end
  if Window.frontmostWindow():application():bundleID() ~= "com.apple.finder" then
    return
  end
  local axApplication = AX.applicationElement(finderAppObj)
  -- if a file's name is currently being edited
  if UI.getUIElement(axApplication, {{"AXTextField", 1}}) then
    return
  end
  local focusedElement = axApplication:attributeValue("AXFocusedUIElement")
  if not focusedElement then
    return
  end
  local focusedElementDescription = focusedElement:attributeValue("AXDescription")
  -- ONLY in icon/gallery views,
  -- it will appear as if the files themselves are focused, even if there's an active context menu
  if focusedElementDescription == "icon view" or focusedElementDescription == "gallery view" then
    -- column view
    -- checking for an active context menu
    local contextMenu = focusedElement:attributeValue("AXChildren")[2]
    if (contextMenu and contextMenu:attributeValue("AXRole") == "AXMenu") then
      return
    end
  elseif focusedElement:attributeValue("AXRole") == "AXList" then
    -- if the description is list view,
    -- then we can count the Accessibility API that the files area is indeed focused
    local axBrowser = focusedElement:attributeValue("AXParent"):attributeValue("AXParent"):attributeValue("AXParent")
    if axBrowser:attributeValue("AXDescription") ~= "column view" then
      return
    end
  elseif focusedElementDescription ~= "list view" then
    return
  end
  -- EDGE CASES --
  -- TODO: check for an mission control/dock (element at position)
  -- TODO: check for Contexts.app
  -- checking for open toolbar menus
  local toolbar =
    UI.getUIElement(
    axApplication,
    {
      {"AXWindow", "AXMain", true},
      {"AXToolbar", 1}
    }
  )
  if toolbar then
    for _, toolbarItem in ipairs(toolbar:attributeValue("AXChildren")) do
      local firstElement = toolbarItem:attributeValue("AXChildren")
      if firstElement then
        -- axmenu!
        if toolbarItem[2] then
          return
        end
      end
    end
  end
  -- checking for an open popup menu in a notification banner
  if
    UI.getUIElement(
      Application("Notification Center"),
      {
        {"AXWindow", 1},
        {"AXMenuButton", 1},
        {"AXMenu", 1},
        {"AXMenuItem", 1}
      }
    )
   then
    return
  end
  -- if we reached here, the file area is focused
  return true
end

return obj
