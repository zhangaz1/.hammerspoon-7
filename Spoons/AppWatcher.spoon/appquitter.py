#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
import plistlib
import os
import signal
from subprocess import check_output
from datetime import datetime
import AppKit

# https://stackoverflow.com/questions/6337513/how-can-i-debug-a-launchd-script-that-doesnt-run-on-startup

now = datetime.now()
NOW_STRING = "{}:{}".format(now.hour, now.minute)

print("")
print("==> " + NOW_STRING + ": Session begin")

running_apps = {}

for app in AppKit.NSWorkspace.sharedWorkspace().runningApplications():
    bundle_id = app.bundleIdentifier()
    running_apps[bundle_id] = app.processIdentifier()

plist_path = os.path.expanduser(
    "~/Library/Preferences/com.rb.hs.appquitter.tracker.plist")
plist_obj = plistlib.readPlist(plist_path)

APPLESCRIPT = """
on run argv
    set theID to (item 1 of argv)
	tell application "System Events"
        if not (exists (application process 1 whose bundle identifier is theID)) then
		    return
	    end if
        tell (application process 1 whose bundle identifier is theID)
            if visible then
                set visible to false
            end if
        end tell
	end tell
end run
"""

inactive_apps = []
skipped = []
scheduled = []
performed = []

new_plist = {}

for bundle_id in plist_obj:
    # inactive apps
    if bundle_id not in running_apps.keys():
        # delete keys for inactive apps
        # del plist_obj[bundle_id]
        inactive_apps.append(bundle_id)
        continue

    new_plist[bundle_id] = {"id": bundle_id}
    for operation in plist_obj[bundle_id]:
        if operation == "id":
            continue
        scheduled_action_time = plist_obj[bundle_id][operation]
        readable_time = datetime.fromtimestamp(scheduled_action_time)
        hour = str(readable_time.hour).zfill(2)
        minute = str(readable_time.minute).zfill(2)
        READABLE_TIME_STRING = "{}:{}".format(hour, minute)

        if scheduled_action_time == 0:
            TEXT = "{} ({})".format(bundle_id, operation)
            skipped.append(TEXT)
            new_plist[bundle_id][operation] = 0
            continue

        if scheduled_action_time > time.time():
            TEXT = "{} ({}) @ {}".format(bundle_id, operation, READABLE_TIME_STRING)
            scheduled.append(TEXT)
            new_plist[bundle_id][operation] = scheduled_action_time
            continue

        if operation == "quit":
            os.kill(running_apps[bundle_id], signal.SIGINT)
        if operation == "hide":
            check_output(["/usr/bin/osascript", "-e", APPLESCRIPT, bundle_id])

        TEXT = "{} ({})".format(bundle_id, operation)
        performed.append(TEXT)
        new_plist[bundle_id][operation] = 0

plistlib.writePlist(new_plist, plist_path)

print("==> Skipped (inactive app): {}".format(len(inactive_apps)))
print("==> Skipped (zeroed timer): " + "\n" + "\n".join(skipped))
print("==> Scheduled: " + "\n" + "\n".join(scheduled))
print("==> Performed: " + "\n" + "\n".join(performed))
print("==> Session end")
print("")
