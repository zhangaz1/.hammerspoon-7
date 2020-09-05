local Application = require("hs.application")
local Webview = require("hs.webview")
local Drawing = require("hs.drawing")
local Screen = require("hs.screen")
local Fnutils = require("hs.fnutils")
local Spoons = require("hs.spoons")
local util = require("rb.util")

local obj = {}

obj.__index = obj
obj.name = "KSheet"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Workaround for "Dictation" menuitem
Application.menuGlyphs[148] = "fn fn"

obj.commandEnum = {cmd = "⌘", shift = "⇧", alt = "⌥", ctrl = "⌃"}

local function processMenuItems(menustru)
  local menu = ""
  for pos, val in pairs(menustru) do
    if type(val) == "table" then
      -- TODO: Remove menubar items with no shortcuts in them
      if val.AXRole == "AXMenuBarItem" and type(val.AXChildren) == "table" then
        menu = menu .. "<ul class='col col" .. pos .. "'>"
        menu = menu .. "<li class='title'><strong>" .. val.AXTitle .. "</strong></li>"
        menu = menu .. processMenuItems(val.AXChildren[1])
        menu = menu .. "</ul>"
      elseif val.AXRole == "AXMenuItem" and not val.AXChildren then
        if not (val.AXMenuItemCmdChar == "" and val.AXMenuItemCmdGlyph == "") then
          local CmdModifiers = ""
          for _, value in pairs(val.AXMenuItemCmdModifiers) do
            CmdModifiers = CmdModifiers .. obj.commandEnum[value]
          end
          local CmdChar = val.AXMenuItemCmdChar
          local CmdGlyph = Application.menuGlyphs[val.AXMenuItemCmdGlyph] or ""
          local CmdKeys = CmdChar .. CmdGlyph
          menu =
            menu ..
            string.format(
              "<li><div class='cmdModifiers'>%s %s</div><div class='cmdtext'> %s</div></li>",
              CmdModifiers,
              CmdKeys,
              val.AXTitle
            )
        end
      elseif val.AXRole == "AXMenuItem" and type(val.AXChildren) == "table" then
        menu = menu .. processMenuItems(val.AXChildren[1])
      end
    end
  end
  return menu
end

local function generateHtml(application)
  local app_title = application:title()
  local menuitems_tree = application:getMenuItems()
  local allmenuitems = processMenuItems(menuitems_tree)
  local html =
    string.format(
    [[
      <!DOCTYPE html>
      <html>
        <head>
          <style type="text/css">
            * {
              margin: 0;
              padding: 0;
            }
            html,
            body {
              background-color: %s;
              color: %s;
              font-family: -apple-system;
              font-size: 13px;
            }
            a {
              text-decoration: none;
              font-size: 12px;
            }
            li.title {
              text-align: center;
            }
            ul,
            li {
              list-style: inside none;
              padding: 0 0 5px;
            }
            header {
              position: fixed;
              top: 0;
              left: 0;
              right: 0;
              height: 48px;
              z-index: 99;
            }
            header hr {
              border: 0;
              height: 0;
              border-top: 1px solid rgba(0, 0, 0, 0.1);
              border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            }
            .title {
              padding: 15px;
            }
            li.title {
              padding: 0 10px 15px;
            }
            .content {
              padding: 0 0 15px;
              font-size: 12px;
              overflow: hidden;
            }
            .content.maincontent {
              position: relative;
              height: 577px;
              margin-top: 46px;
            }
            .content > .col {
              width: 23%%;
              padding: 20px 0 20px 20px;
            }
            li:after {
              visibility: hidden;
              display: block;
              font-size: 0;
              content: " ";
              clear: both;
              height: 0;
            }
            .cmdModifiers {
              width: 60px;
              padding-right: 15px;
              text-align: right;
              float: left;
              font-weight: bold;
            }
            .cmdtext {
              float: left;
              overflow: hidden;
              width: 165px;
            }
          </style>
        </head>
        <body>
          <div class="content maincontent">%s</div>
          <br />
          <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/2.2.2/isotope.pkgd.min.js"></script>
          <script type="text/javascript">
            var elem = document.querySelector(".content");
            var iso = new Isotope(elem, {
              // options
              itemSelector: ".col",
              layoutMode: "masonry"
            });
          </script>
        </body>
      </html>
      ]],
    util.winBackgroundColor(),
    util.labelColor(),
    allmenuitems
  )
  return html, app_title
end

function obj:show()
  local capp = Application.frontmostApplication()
  local cscreen = Screen.mainScreen()
  local cres = cscreen:fullFrame()
  self.sheetView:frame(
    {
      x = cres.x + cres.w * 0.15 / 2,
      y = cres.y + cres.h * 0.25 / 2,
      w = cres.w * 0.85,
      h = cres.h * 0.75
    }
  )
  local webcontent, app_title = generateHtml(capp)
  self.sheetView:windowTitle(app_title)
  self.sheetView:html(webcontent)
  self.sheetView:show()
end

function obj:hide()
  self.sheetView:hide()
end

function obj:toggle()
  if self.sheetView and self.sheetView:hswindow() and self.sheetView:hswindow():isVisible() then
    self:hide()
  else
    self:show()
  end
end

function obj:bindHotkeys(mapping)
  local actions = {
    toggle = Fnutils.partial(self.toggle, self),
    show = Fnutils.partial(self.show, self),
    hide = Fnutils.partial(self.hide, self)
  }
  Spoons.bindHotkeysToSpec(actions, mapping)
end

function obj:start()
end

function obj:init()
  self.sheetView = Webview.new({x = 0, y = 0, w = 0, h = 0})
  self.sheetView:windowStyle({"titled", "closable", "nonactivating"})
  self.sheetView:closeOnEscape(true)
  self.sheetView:allowGestures(true)
  self.sheetView:allowNewWindows(false)
  self.sheetView:level(Drawing.windowLevels.modalPanel)
end

return obj
