#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
import subprocess
import plistlib
import os
import signal
import AppKit
from datetime import datetime

runningApps = {}

# https://stackoverflow.com/questions/6337513/how-can-i-debug-a-launchd-script-that-doesnt-run-on-startup

for app in AppKit.NSWorkspace.sharedWorkspace().launchedApplications():
    bundle_id = app.get("NSApplicationBundleIdentifier")
    runningApps[bundle_id] = app.get("NSApplicationProcessIdentifier")

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


def msg(bundle_id, scheduled, operation, readable):
    print("{now} ==> {id}: {scheduled} {operation} AT {readable}".format(
        now=datetime.now(),
        id=bundle_id,
        scheduled="SCHEDULED FOR" if scheduled else "PERFORMING",
        operation=operation,
        readable=readable))


for bundle_id in plist_obj:
    # inactive apps
    if bundle_id not in runningApps.keys():
        continue
    for operation in plist_obj[bundle_id]:
        # ignore human-readable entries
        if "human_readable" in operation:
            continue
        invocation_time = plist_obj[bundle_id][operation]
        readable = datetime.fromtimestamp(invocation_time)
        # ignore stopped timers
        if invocation_time == 0:
            continue
        if invocation_time > time.time():
            msg(bundle_id, True, operation, readable)
            continue
        if "quit" in operation:
            os.kill(runningApps[bundle_id], signal.SIGTERM)
            msg(bundle_id, False, operation, readable)
        elif "hide" in operation:
            subprocess.check_output(
                ["/usr/bin/osascript", "-e", applescript, bundle_id])
            plist_obj[bundle_id][operation] = 0
            plistlib.writePlist(plist_obj, plist_path)
            msg(bundle_id, False, operation, readable)
