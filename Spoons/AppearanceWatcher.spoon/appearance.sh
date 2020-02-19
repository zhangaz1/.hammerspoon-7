#!/bin/bash

MODE="${1}"

if [[ "${MODE}" != "light" ]] && [[ "${MODE}" != "dark" ]]; then
	printf "%s\n" "USAGE: $(basename "${SOURCE}") (dark|light)"
	exit 0
fi

### restart whatsapp when transitioning to dark mode ###
if [[ "${MODE}" == "dark" ]]; then
	if ps -A | grep -iE --silent "macos/whatsapp$"; then
		killall -9 "WhatsApp"
		sleep 1
		open -jga "WhatsApp"
	fi
fi

### vscode ###
if [[ "${MODE}" == "dark" ]]; then
	vscode_theme="Solarized Dark"
elif [[ "${MODE}" == "light" ]]; then
	vscode_theme="Solarized Light"
fi
vscode_settings_file="${HOME}/Library/Application Support/Code/User/settings.json"
if ! grep --silent "\"workbench.colorTheme\": \"${vscode_theme}\"" "${vscode_settings_file}"; then
	sed -E -i .bak "s|(\"workbench.colorTheme\":).+$|\1 \"${vscode_theme}\",|" "${vscode_settings_file}" &
fi

### launchbar ###
if [[ "${MODE}" == "dark" ]]; then
	launchbar_theme="at.obdev.LaunchBar.theme.Dark"
elif [[ "${MODE}" == "light" ]]; then
	launchbar_theme="at.obdev.LaunchBar.theme.Default"
fi
defaults write "at.obdev.LaunchBar" Theme -string "${launchbar_theme}" &

### cardhop ###
if [[ "${MODE}" == "dark" ]]; then
	arg=false
elif [[ "${MODE}" == "light" ]]; then
	arg=true
fi
defaults write "com.flexibits.cardhop.mac" LightTheme -bool "${arg}" &

### contexts ###
if [[ "${MODE}" == "dark" ]]; then
	contexts_theme="CTAppearanceNamedVibrantDark"
elif [[ "${MODE}" == "light" ]]; then
	contexts_theme="CTAppearanceNamedSubtle"
fi
if [[ "$(defaults read "com.contextsformac.Contexts" CTAppearanceTheme)" != "${contexts_theme}" ]]; then
	(
		defaults write "com.contextsformac.Contexts" CTAppearanceTheme -string "${contexts_theme}"
		/usr/bin/osascript <<-EOF
			tell application "Contexts"
				quit
				delay 1
				activate
			end tell
			tell application "System Events" to click button 1 of window 1 of application process "Contexts"
		EOF
	) &>/dev/null &
fi

# hammerspoon's console
if [[ "${MODE}" == "dark" ]]; then
	HS="true"
elif [[ "${MODE}" == "light" ]]; then
	HS="false"
fi
osascript -e "tell application \"Hammerspoon\" to execute lua code \"hs.console.darkMode(${HS})\"" &>/dev/null &

### iterm ###
/usr/bin/osascript -e 'tell application "iTerm" to launch API script named "changeColorPreset.py"' &
