#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
import plistlib
import os
from subprocess import check_output
from datetime import datetime

# https://stackoverflow.com/questions/6337513/how-can-i-debug-a-launchd-script-that-doesnt-run-on-startup


def is_running(app):
    script = """
    on run argv
	    return application id (item 1 of argv) is running
    end run
    """
    result = check_output(
        ["/usr/bin/osascript", "-e", script, app]).rstrip()
    return result == "true"


def is_hidden(app):
    script = """
    on run argv
        tell application "System Events"
            return visible of (application process 1 whose bundle identifier is (item 1 of argv))
        end tell
    end run
    """
    result = check_output(
        ["/usr/bin/osascript", "-e", script, app]).rstrip()
    return result == "true"


def is_frontmost(app):
    script = """
    on run argv
        return application id (item 1 of argv) is frontmost
    end run
    """
    result = check_output(
        ["/usr/bin/osascript", "-e", script, app]).rstrip()
    return result == "true"


def hide_app(app):
    script = """
    on run argv
        tell application "System Events"
            tell (application process 1 whose bundle identifier is (item 1 of argv))
                set visible to false
            end tell
        end tell
    end run
    """
    check_output(
        ["/usr/bin/osascript", "-e", script, app])


def quit_app(app):
    script = """
    on run argv
	    tell application id (item 1 of argv) to quit
    end run
    """
    check_output(
        ["/usr/bin/osascript", "-e", script, app])


PLIST_PATH = os.path.expanduser(
    "~/Library/Preferences/com.rb.hs.appquitter.tracker.plist")
plist_obj = plistlib.readPlist(PLIST_PATH)

new_plist = {}

now = datetime.now()
NOW_STRING = "{}:{}".format(now.hour, now.minute)
print("==> appquitter.py ==> " + NOW_STRING + ": Session begin")

for bundle_id in plist_obj:
    if not is_running(bundle_id):
        # if the app is already not running, it's not interesting anymore
        print("not running " + bundle_id)
        continue

    for operation_key in plist_obj[bundle_id]:
        scheduled_action_time = plist_obj[bundle_id][operation_key]

        if scheduled_action_time > time.time():
            if bundle_id not in new_plist:
                new_plist[bundle_id] = {}
            new_plist[bundle_id][operation_key] = scheduled_action_time
            print("scheduled " + " " + operation_key + " ==> " + bundle_id)
            continue

        if operation_key == "quit":
            print("quitting " + bundle_id)
            quit_app(bundle_id)
        # just hide
        if operation_key == "hide":
            print("hiding " + bundle_id)
            hide_app(bundle_id)


plistlib.writePlist(new_plist, PLIST_PATH)
