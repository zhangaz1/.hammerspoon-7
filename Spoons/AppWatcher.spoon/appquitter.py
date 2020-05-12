#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
import subprocess
import plistlib
import os
import signal
import AppKit
from datetime import datetime

# https://stackoverflow.com/questions/6337513/how-can-i-debug-a-launchd-script-that-doesnt-run-on-startup

now = datetime.now()
nowString = "{}:{}".format(now.hour, now.minute)

print("")
print(nowString + ": SESSION BEGIN")

runningApps = {}

for app in AppKit.NSWorkspace.sharedWorkspace().runningApplications():
    bundle_id = app.bundleIdentifier()
    runningApps[bundle_id] = app.processIdentifier()

plist_path = os.path.expanduser(
    "~/Library/Preferences/com.rb.hs.appquitter.tracker.plist")
plist_obj = plistlib.readPlist(plist_path)

applescript = """
on run argv
	tell application "System Events"
		tell (application process 1 whose bundle identifier is (item 1 of argv))
			set visible to false
		end tell
	end tell
end run
"""

for bundle_id in plist_obj:
    # inactive apps
    if bundle_id not in runningApps.keys():
        text = bundle_id + " => skipping (APP NOT RUNNING)"
        print(nowString + ": " + text)
        continue
    for operation in plist_obj[bundle_id]:
        if "_DEBUG" in operation or operation == "id":
            continue
        invocation_time = plist_obj[bundle_id][operation]
        # stopped timers
        readable_time = datetime.fromtimestamp(invocation_time)
        hour = readable_time.hour
        minute = readable_time.minute
        readable_time_string = "{}:{}".format(hour, minute)
        if invocation_time == 0:
            text = "{} => SKIPPING {}, TIMER STOPPED".format(
                bundle_id, operation)
            print(nowString + ": " + text)
            continue
        # future timers
        if invocation_time > time.time():
            text = "{} => SKIPPING {}, SCHEDULED FOR {}".format(
                bundle_id, operation, readable_time_string)
            print(nowString + ": " + text)
            continue
        if operation == "quit":
            os.kill(runningApps[bundle_id], signal.SIGTERM)
        elif operation == "hide":
            subprocess.check_output(
                ["/usr/bin/osascript", "-e", applescript, bundle_id])

        plist_obj[bundle_id][operation] = 0
        plist_obj[bundle_id][operation + "_DEBUG"] = ""
        plistlib.writePlist(plist_obj, plist_path)
        text = "{} => PERFORMING {}".format(
            bundle_id, operation)
        print(nowString + ": " + text)

print(nowString + ": SESSION END")
print("")
