# .hammerspoon

Personal [Hammerspoon](https://github.com/Hammerspoon/hammerspoon) config.

## Features

- Modular and Spoon-based.
- Documented.
- Easy on system resources, even with all Spoons loaded. There are no redundant global objects, like application watchers. Furthermore, application specific objects like event taps and UI observers are stopped when the target app is deactivated.

## API

## Notes

- Spoons with names prefixed with an underscore are app-specific. They must be used in conjunction with `AppSpoonsManager.spoon` and `AppWatcher.spoon`, and will be activated when the target app gains focus.

### To Do

- Organize dependencies in Spoons.
- Documentation and API for the app-specific Spoons.

## Acknowledgements

- [dharmapoudel](https://github.com/dharmapoudel), for KSheet.spoon.
