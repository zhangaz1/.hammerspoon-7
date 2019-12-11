local application = require("hs.application")
local hotkey = require("hs.hotkey")
local Chooser = require("hs.chooser")

local obj = {}


local function chooserCallback(choice)
  spoon.AppWatcher.appEnvs[choice.appEnvIndex].appScripts[choice.funcIndex].func()
end

local chooser = Chooser.new(chooserCallback)

local function presentScripts(forApplication)
	local scripts = {}
  for appEnvIndex, file in ipairs(spoon.AppWatcher.appEnvs) do
		if file.id == forApplication:bundleID() then
			if file.appScripts then
				for funcIndex, script in ipairs(file.appScripts) do
					table.insert(scripts, {
						text = script.title,
						subText = 'Application Script',
						funcIndex = funcIndex,
						appEnvIndex = appEnvIndex
					})
				end
      end
      break
		end
	end
	return scripts
end

function obj.start()
  local frontApp = application:frontmostApplication()
  local choices = presentScripts(frontApp)
	-- Chooser.start(chooserCallback, choices, {"text"})
	chooser:choices(choices):show()
end

hotkey.bind(
  {"alt"},
  "q",
  function()
    obj.start()
  end
)
