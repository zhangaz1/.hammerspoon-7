#!/bin/bash

MODE="${1}"

if [[ "${MODE}" != "light" ]] &&  [[ "${MODE}" != "dark" ]]; then
	printf "%s\n" "USAGE: $(basename "${SOURCE}") (dark|light)"
	exit 0
fi

### iterm ###
ITERMSCRIPT="${HOME}/Library/Application Support/iTerm2/Scripts/AutoLaunch/changeColorPreset.py"
if [[ -f "${ITERMSCRIPT}" ]]
then
	if [[ "${MODE}" == "dark" ]]; then
		ITERM="Solarized Dark"
	elif [[ "${MODE}" == "light" ]]; then
		ITERM="Solarized Light"
	fi
	ITERMDIR="${HOME}/Library/Application Support/iTerm2/iterm2env"
	if [[ -d "${ITERMDIR}" ]]
	then
		for pythonVersion in "${ITERMDIR}/versions/"*"/bin/python3"
		do
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
if ! grep --silent "\"workbench.colorTheme\": \"${VSCODE}\"" "${VSCODESETTINGSFILE}"
then
	/usr/bin/sed -E -i .bak "s|(\"workbench.colorTheme\":).+$|\1 \"${VSCODE}\",|" "${VSCODESETTINGSFILE}" &
fi

### launchbar ###
if [[ "${MODE}" == "dark" ]]; then
	LAUNCHBAR="at.obdev.LaunchBar.theme.Dark"
elif [[ "${MODE}" == "light" ]]; then
	LAUNCHBAR="at.obdev.LaunchBar.theme.Default"
fi
defaults write "at.obdev.LaunchBar" Theme -string "${LAUNCHBAR}"

### cardhop ###
if [[ "${MODE}" == "dark" ]]; then
	arg=false
elif [[ "${MODE}" == "light" ]]; then
	arg=true
fi
defaults write "com.flexibits.cardhop.mac" LightTheme -bool "${arg}"

### contexts ###
if [[ "${MODE}" == "dark" ]]; then
	CONTEXTS="CTAppearanceNamedVibrantDark"
elif [[ "${MODE}" == "light" ]]; then
	CONTEXTS="CTAppearanceNamedSubtle"
fi
if [[ "$(defaults read "com.contextsformac.Contexts" CTAppearanceTheme)" != "${CONTEXTS}" ]]
then
	defaults write "com.contextsformac.Contexts" CTAppearanceTheme -string "${CONTEXTS}"
	killall Contexts
	sleep 1
	open -j -g -a Contexts
fi


# hammerspoon's console
run=false
hsDarkThemeOn="$(defaults read org.hammerspoon.Hammerspoon HSConsoleDarkModeKey)"
if [[ "${MODE}" == "dark" ]]; then
	if [[ "${hsDarkThemeOn}" == "0" ]]
	then
		HS="true"
		run=true
	fi
elif [[ "${MODE}" == "light" ]]; then
		if [[ "${hsDarkThemeOn}" == "1" ]]
		then
			HS="false"
			run=true
		fi
fi
if "${run}"
then
	/usr/bin/osascript -e "tell application \"Hammerspoon\" to execute lua code \"hs.console.darkMode(${HS})\"" &>/dev/null &
fi
