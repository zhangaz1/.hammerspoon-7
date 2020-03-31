#!/bin/bash

MODE="${1}"

if [[ "${MODE}" != "light" ]] && [[ "${MODE}" != "dark" ]]; then
	/usr/bin/printf "%s\n" "USAGE: $(/usr/bin/basename "${SOURCE}") (dark|light)"
	exit 0
fi

### restart whatsapp when transitioning to dark mode ###
if [[ "${MODE}" == "dark" ]]; then
	if /bin/ps -A | /usr/bin/grep -iE --silent "macos/whatsapp$"; then
		{ /usr/bin/killall -9 "WhatsApp"
		/bin/sleep 1
		/usr/bin/open -jga "WhatsApp"
		/bin/sleep 1
		/usr/bin/osascript <<-EOF
			tell application "System Events"
				tell application process "WhatsApp"
					set visible to false
				end tell
			end tell
		EOF
		 } &
	fi
fi

### vscode ###
if [[ "${MODE}" == "dark" ]]; then
	vscode_theme="Solarized Dark"
elif [[ "${MODE}" == "light" ]]; then
	vscode_theme="Solarized Light"
fi
vscode_settings_file="${HOME}/Library/Application Support/Code/User/settings.json"
if ! /usr/bin/grep --silent "\"workbench.colorTheme\": \"${vscode_theme}\"" "${vscode_settings_file}"; then
	/usr/bin/sed -E -i .bak "s|(\"workbench.colorTheme\":).+$|\1 \"${vscode_theme}\",|" "${vscode_settings_file}" &
fi

### launchbar ###
if [[ "${MODE}" == "dark" ]]; then
	launchbar_theme="at.obdev.LaunchBar.theme.Dark"
elif [[ "${MODE}" == "light" ]]; then
	launchbar_theme="at.obdev.LaunchBar.theme.Default"
fi
/usr/bin/defaults write "at.obdev.LaunchBar" Theme -string "${launchbar_theme}" &

### cardhop ###
if [[ "${MODE}" == "dark" ]]; then
	arg=false
elif [[ "${MODE}" == "light" ]]; then
	arg=true
fi
/usr/bin/defaults write "com.flexibits.cardhop.mac" LightTheme -bool "${arg}" &

### contexts ###
if [[ "${MODE}" == "dark" ]]; then
	contexts_theme="CTAppearanceNamedVibrantDark"
elif [[ "${MODE}" == "light" ]]; then
	contexts_theme="CTAppearanceNamedSubtle"
fi
if [[ "$(/usr/bin/defaults read "com.contextsformac.Contexts" CTAppearanceTheme)" != "${contexts_theme}" ]]; then
	{
		/usr/bin/defaults write "com.contextsformac.Contexts" CTAppearanceTheme -string "${contexts_theme}"
		/usr/bin/killall "Contexts"
		/bin/sleep 1
		open -a "Contexts"
		/bin/sleep 1
		/usr/bin/osascript -e 'tell application "System Events" to click button 1 of window 1 of application process "Contexts"'
	} &>/dev/null &
fi

# hammerspoon's console
if [[ "${MODE}" == "dark" ]]; then
	HS="true"
elif [[ "${MODE}" == "light" ]]; then
	HS="false"
fi
/usr/bin/osascript -e "tell application \"Hammerspoon\" to execute lua code \"hs.console.darkMode(${HS})\"" &>/dev/null &

### iterm ###
/usr/bin/osascript -e 'tell application "iTerm" to launch API script named "changeColorPreset.py"' &
