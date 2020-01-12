#!/bin/bash

MODE="${1}"

if [[ "${MODE}" != "light" ]] && [[ "${MODE}" != "dark" ]]; then
	printf "%s\n" "USAGE: $(basename "${SOURCE}") (dark|light)"
	exit 0
fi

### iterm ###
ITERMSCRIPT="${HOME}/Library/Application Support/iTerm2/Scripts/AutoLaunch/changeColorPreset.py"
if [[ -f "${ITERMSCRIPT}" ]]; then
	if [[ "${MODE}" == "dark" ]]; then
		ITERM="XCode-Dark"
	elif [[ "${MODE}" == "light" ]]; then
		ITERM="XCode-Default-Light"
	fi
	ITERMDIR="${HOME}/Library/Application Support/iTerm2/iterm2env"
	if [[ -d "${ITERMDIR}" ]]; then
		for pythonVersion in "${ITERMDIR}/versions/"*"/bin/python3"; do
			"${pythonVersion}" "${ITERMSCRIPT}" "${ITERM}" &
			break
		done
	fi
fi

### vscode ###
if [[ "${MODE}" == "dark" ]]; then
	VSCODE="Solarized Dark"
elif [[ "${MODE}" == "light" ]]; then
	VSCODE="Solarized Light"
fi
VSCODESETTINGSFILE="${HOME}/Library/Application Support/Code/User/settings.json"
if ! grep --silent "\"workbench.colorTheme\": \"${VSCODE}\"" "${VSCODESETTINGSFILE}"; then
	sed -E -i .bak "s|(\"workbench.colorTheme\":).+$|\1 \"${VSCODE}\",|" "${VSCODESETTINGSFILE}" &
fi

### launchbar ###
if [[ "${MODE}" == "dark" ]]; then
	LAUNCHBAR="at.obdev.LaunchBar.theme.Dark"
elif [[ "${MODE}" == "light" ]]; then
	LAUNCHBAR="at.obdev.LaunchBar.theme.Default"
fi
defaults write "at.obdev.LaunchBar" Theme -string "${LAUNCHBAR}" &

### cardhop ###
if [[ "${MODE}" == "dark" ]]; then
	arg=false
elif [[ "${MODE}" == "light" ]]; then
	arg=true
fi
defaults write "com.flexibits.cardhop.mac" LightTheme -bool "${arg}" &

### contexts ###
if [[ "${MODE}" == "dark" ]]; then
	CONTEXTS="CTAppearanceNamedVibrantDark"
elif [[ "${MODE}" == "light" ]]; then
	CONTEXTS="CTAppearanceNamedSubtle"
fi
if [[ "$(defaults read "com.contextsformac.Contexts" CTAppearanceTheme)" != "${CONTEXTS}" ]]; then
	(
		defaults write "com.contextsformac.Contexts" CTAppearanceTheme -string "${CONTEXTS}"
		/usr/bin/osascript <<-EOF
			tell application "Contexts"
				quit
				delay 1
				activate
			end tell
			tell application "System Events" to click button 1 of window 1 of application process "Contexts"
		EOF
	) &
fi

# hammerspoon's console
if [[ "${MODE}" == "dark" ]]; then
	HS="true"
elif [[ "${MODE}" == "light" ]]; then
	HS="false"
fi
osascript -e "tell application \"Hammerspoon\" to execute lua code \"hs.console.darkMode(${HS})\"" &>/dev/null &
