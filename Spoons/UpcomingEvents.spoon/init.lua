local Task = require("hs.task")
local FNutils = require("hs.fnutils")
local Image = require("hs.image")

local Chooser = require("util.GlobalChooser")

local obj = {}

obj.__index = obj
obj.name = "CalendarEvents"
obj.version = "1.0"
obj.author = "roeybiran <roeybiran@icloud.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local workflow = script_path() .. "/get_events.workflow"

local function automatorCallback(_, out, _)
  local choices = {}
  local uidsOrSummaries = FNutils.split(out, "TOTAL EVENTS")
  local uidsTable = {}
  local uids = uidsOrSummaries[1]
  for uid in string.gmatch(uids, "localUID:([%w-]+)") do table.insert(uidsTable, uid) end

  local events = uidsOrSummaries[2]
  local eventsTable = FNutils.split(events, "EVENT %d+ OF %d+")
  table.remove(eventsTable, 1)
  table.remove(eventsTable, #eventsTable)
  for i, event in ipairs(eventsTable) do
    local eventDetails = FNutils.split(event, "\n")
    eventDetails = FNutils.filter(eventDetails, function(x) return (x ~= "") end)

    local title = eventDetails[1]:gsub("Summary:\t", "")
    local date = FNutils.split(eventDetails[3]:gsub("Date:\t", ""), " to ")
    local startDate = date[1]
    local endDate = date[2]
    local time = FNutils.split(eventDetails[4]:gsub("Time:\t", ""), " to ")
    local startTime = time[1]
    local endTime = time[2]
    local uid = uidsTable[i]

    if startTime == endTime then
      time = startTime
    else
      time = startTime .. "-" .. endTime
    end

    if startDate == endDate then
      date = startDate
    else
      date = startDate .. "-" .. endDate
    end

    local item = {
      text = title,
      subText = date .. ", " .. time,
      uid = uid,
      image = Image.imageFromAppBundle("com.apple.iCal")
    }
    table.insert(choices, item)
  end
  Chooser:start(nil, choices, {"text"})
end

function obj:start()
  -- body
  Task.new("/usr/bin/automator", automatorCallback, {workflow}):start()
end

function obj:init() end

return obj
