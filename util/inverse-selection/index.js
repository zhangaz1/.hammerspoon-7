"use strict";

const toHfs = require("@roeybiran/posix-to-hfs");
const path = require("path");
const shallowGlob = require("/Users/roey/Dropbox/projects/node/shallow-glob");
const { execFile } = require("@roeybiran/task");

const script = path.join(__dirname, "selectInFinder.scpt");

(async () => {
  let finderSelection = await execFile("/usr/bin/osascript", [
    "-e",
    `set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {linefeed}}
    tell application "Finder" to return ((selection as alias list) as text)
    set AppleScript's text item delimiters to saveTID`
  ]);

  finderSelection = finderSelection.stdout.split("\n").map(selectedItem => {
    if (selectedItem.endsWith(":")) {
      return selectedItem.replace(/.$/, "");
    }
    return selectedItem;
  });

  let targetFolder = finderSelection[0];
  targetFolder = targetFolder.match(/(^.+?:)(.+)(:.+$)/)[2].replace(/:/g, "/");
  targetFolder = `/${targetFolder}`;

  let globs = await shallowGlob(targetFolder);
  globs = await toHfs(globs);
  globs = globs.filter(x => !finderSelection.includes(x));

  try {
    await execFile("/usr/bin/osascript", [script, ...globs]);
  } catch (error) {
    console.log(error);
  }
})();
