# .hammerspoon

Personal [Hammerspoon](https://github.com/Hammerspoon/hammerspoon) config.

## Features

- Modular and Spoon-based.
- Documented.
- Easy on system resources, even with all Spoons loaded. There are no redundant global objects, like application watchers. Furthermore, application specific objects like event taps and UI observers are stopped when the target app is deactivated.

## Notes

- Spoons with names prefixed with an underscore are app-specific. They must be used in conjunction with `AppSpoonsManager.spoon` and `AppWatcher.spoon`, and will be activated when the target app gains focus.

## API

### AppQuitter.spoon

Leverages `launchd` to quit and/or hide inactive apps.

#### AppQuitter:update(event, bundleID)

_Method_

Updates the module's timers.

**Parameters:**

- event - A string, one of the `hs.application.watcher` event constants.
- bundleID - A string, the bundle identifier of event-triggering app.

#### AppQuitter:start([rules])

_Method_

Sets up and starts the module. Begins the tracking of running dock apps,
or resumes tracking of a given app if its timer is already running.

**Parameters:**

* rules - a table that defines inactivity periods after which an app will hide/quit.
 - each element must be one of 2 forms:
   - a key value pair. Each key should equal to the bundle identifier string of the app you wish to set rules for.
     - Each value must be a table containing exactly 2 key value pairs: (1) The keys, which are strings, should be named "quit" and "hide".
     - The values for each keys are integers, and they should correspond to the period (in hours) of inactivity before an action takes place.
     - For example: ["com.apple.Safari"] = {quit = 1, hide = 0.2}. This will set a rule for Safari to quit after 1 hour and hide after 12 minutes.
   - a simple string representing that target app's bundle identifier. In this case, the default hide/quit values will be applied.

**Returns:**

* the module object, for method chaining

### AppSpoonsManager.spoon

Manages the activation and deactivation of the app-specific Spoons when an app goes in and out of focus, respectively.

#### AppSpoonsManager:update(appObj, bundleID)

_Method_

Calls the `start()` method of the Spoon for the focused app, and calls `exit()` on all other Spoons. This method must be called in each callback of your `hs.application.watcher` instance.

**Parameters:**

- appObj - the `hs.application` object of the frontmost app.
- bundleID - a string, the bundle identifier of the frontmost app.

### AppWatcher.spoon

An `hs.application.watcher` instance bolstered by `hs.window.filter` to catch and react on activation of "transient" apps, such as Spotlight and the 1Password 7 mini window.

#### AppWatcher.transientApps

_Variable_

A table containing apps you consider to be transient and want to be taken into account by the window filter. Elements should have the same structure as the `filters` parameter of hs.window.filter `setFilters` method.

#### AppWatcher.stop()

_Method_

Stops the module.

#### AppWatcher:start()

_Method_

Starts the module.

### AppearanceWatcher.spoon

Perform actions when the system's theme changes. Actions can be configured by editing the shell script inside the Spoon's directory.

#### AppearanceWatcher:stop()

_Method_

Stops this module.

#### AppearanceWatcher:start()

_Method_

starts this module.

#### AppearanceWatcher:toggle()

_Method_

Toggles this module.

#### AppearanceWatcher:isActive()

_Method_

Determines whether module is active.

**Returns:**

- A boolean, true if the module's watcher is active, otherwise false

### BrightnessControl.spoon

Enters a transient mode in which the left and right arrow keys decrease and increase the system's brightness, respectively.

#### BrightnessControl:start()

_Method_

Starts the module.

#### BrightnessControl:stop()

_Method_

Stops the module. Bound to the escape and return keys.

#### BrightnessControl.increaseBrightnessKey

_Variable_

A hotkey that increases brightness. It's a table that must include 2 keys, "mods" and "key", each must be of the same type as the first 2 parameters to the `hs.hotkey.bind` method. Defaults to →.

#### BrightnessControl.decreaseBrightnessKey

_Variable_

A hotkey that decreases brightness. It's a table that must include 2 keys, "mods" and "key", each must be of the same type as the first 2 parameters to the `hs.hotkey.bind` method. Defaults to ←.

### ConfigWatcher.spoon

Reload the environment when .lua files in ~/.hammerspoon are modified.

#### ConfigWatcher.toggle()

_Method_

Toggles the module.

#### ConfigWatcher.stop()

_Method_

Stops the module.

#### ConfigWatcher.start()

_Method_

Starts the module.

#### ConfigWatcher.toggle()

_Method_


**Returns:**

- A boolean, true if the module is active, otherwise false

### DownloadsWatcher.spoon

Monitor the ~/Downloads folder, and execute a shell script that accepts newly downloaded files as arguments.

#### DownloadsWatcher:stop()

_Method_

Stops the module.

#### DownloadsWatcher:start()

_Method_

Starts the module.

### Globals.spoon

Miscellaneous automations that are not app-specific.

#### Globals:bindHotKeys(_mapping)

_Method_

This module offers the following functionalities:
 - rightClick - simulates a control-click on the currently focused UI element.
 - focusMenuBar - clicks the menu bar item that immediately follows the  menu bar item.
 - focusDock - shows the system-wide dock.

**Parameters:**

 - _mapping - A table that conforms to the structure described in the Spoon plugin documentation.

### KeyboardLayoutManager.spoon

A module that handles automatic keyboard layout switching under varying contexts.

#### KeyboardLayoutManager:setInputSource(bundleid)

_Method_

Switch to an app's last used keyboard layout. Typically, called in an app watcher callback for the activated app.

**Parameters:**

- bundleid - a string, the bundle identifier of the app.

#### KeyboardLayoutManager:bindHotkeys(mapping)

_Method_

Binds hotkeys for this module

**Parameters:**

- mapping - A table containing hotkey modifier/key details for the following items:
 - `toggleInputSource` - switch between the "Hebrew" and "ABC" layouts.

### NotificationCenter.spoon

Notification Center automations.

#### NotificationCenter:bindHotkeys(_mapping)

_Method_

Bind hotkeys for this module. The `_mapping` table keys correspond to the following functionalities:
 - firstButton - clicks on the first (or only) button of a notification center banner. If banners are configured through system preferences to be transient, a mouse move operation will be performed first to try and reveal the button, should it exists.
 - secondButton - clicks on the second button of a notification center banner. If banners are configured through system preferences to be transient, a mouse move operation will be performed first to try and reveal the button, should it exists. If the button is in fact a menu button (that is, it offers a dropdown of additional options), revealing the menu will be favored over a simple click.
 - toggle - Reveal the notification center itself (side bar). Once revealed, a second call of this function will switch between the panel's 2 different modes ("Today" and "Notifications"). Closing the panel could be done normally, e.g. by pressing escape.

**Parameters:**

- _mapping. See the Spoon plugin documentation for the implementation.

### StatusBar.spoon

Enables a status menu item with the familiar Hammerspoon logo, but with customizable contents and a flashing mode to signal ongoing operations.
**Documentation underway**

### VolumeControl.spoon

Clicks on the "volume" status bar item to reveal its volume slider, and enters a modal that allows to control the slider with the arrow keys.

#### VolumeControl:start()

_Method_

Activates the modules and enters the  modal. The following hotkeys/functionalities are available:
 - →: increase volume by a level.
 - ←: decrease volume by a level.
 - ⇧→: increase volume by a couple of levels.
 - ⇧←: decrease volume by a couple of levels.
 - ⌥→: set volume to 100.
 - ⌥←: set volume to 0.
 - escape: close the volume menu and exit the modal (the modal will be exited anyway as soon as the volume menu is closed).

### WifiWatcher.spoon

Respond to changes in the current Wi-Fi network.

#### WifiWatcher:userCallback()

_Method_

A callback to run when the Wi-Fi changes.

**Returns:**

 - the module object, for method chaining.

#### WifiWatcher:start()

_Method_

Starts the Wi-Fi watcher.

**Returns:**

 - the module object, for method chaining.

#### WifiWatcher:stop()

_Method_

Stops the Wi-Fi watcher.

**Returns:**

 - the module object, for method chaining.

#### WifiWatcher:isActive()

_Method_


**Returns:**

- A boolean, true if the watcher is active, otherwise false.

#### WifiWatcher:toggle()

_Method_

Toggles the watcher.

**Returns:**

 - the module object, for method chaining.

### WindowManager.spoon

Moves and resizes windows.

#### WindowManager:bindHotKeys(_mapping)

_Method_

This module offers the following functionalities:
 - maximize - maximizes the frontmost window. If it's already maximized, it will be centered and resized to be a quarter of the screen.
 - pushLeft - moves and/or resizes a window towards the left of the screen.
 - pushRight - moves and/or resizes a window towards the right of the screen.
 - pushDown - moves and/or resizes a window towards the bottom of the screen.
 - pushUp - moves and/or resizes a window towards the top of the screen.
 - pushLeft - moves and/or resizes a window towards the left of the screen.
 - center - centers the frontmost window.

**Parameters:**

 - _mapping - A table that conforms to the structure described in the Spoon plugin documentation.

### WindowManagerModal.spoon

Enables modal hotkeys that allow for more granular control over the size and position of the frontmost window. Shows a small window that serves as a cheat sheet.
**Documentation underway**

### _1Password7.spoon

1Password automations.
**Documentation underway**

### _ActivityMonitor.spoon

Activity Monitor.app automations.
**Documentation underway**

### _AdobeIllustrator.spoon

Adobe Illustrator automations.
**Documentation underway**

### _AdobeInDesign.spoon

Adobe InDesign automations.
**Documentation underway**

### _AppStore.spoon

AppStore automations.
**Documentation underway**

### _Dash.spoon

Dash (version 5 of later) automations.
**Documentation underway**

### _Finder.spoon

Finder automations.
**Documentation underway**

### _Hammerspoon.spoon

Hammerspoon (console) automations
**Documentation underway**

### _Mail.spoon

Mail.app automations.
**Documentation underway**

### _Messages.spoon

Messages.app automations.
**Documentation underway**

### _Notes.spoon

Notes.app automations.
**Documentation underway**

### _Safari.spoon

Safari automations.
**Documentation underway**
## To Do

- Organize dependencies in Spoons.
- Documentation and API for the app-specific Spoons.

## Acknowledgements

- [KSheet.spoon, by dharmapoudel](https://github.com/dharmapoudel)
