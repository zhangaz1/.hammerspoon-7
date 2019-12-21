#!/bin/bash

path="${1}"

parsepath() {
	dir="$(/usr/bin/dirname "${1}")"
	name="$(/usr/bin/basename "${1}" | /usr/bin/cut -f 1 -d '.')"
	printf "%s\n" "${dir}/${name}"
}

case "${path}" in
*".zip")
	target="$(parsepath "${path}")"
	mkdir -p "${target}"
	/usr/bin/ditto -xk "${path}" "${target}"
	/bin/mv -f "${path}" ~/.Trash/
	/usr/bin/printf "%s\n" "${target}"
	;;
*".dmg")
	# target="$(parsepath "${path}")"
	# mkdir -p "${target}"
	mounted_path=$(/usr/bin/yes | /usr/bin/hdiutil attach -nobrowse "${path}" | /usr/bin/tail -n 1 | /usr/bin/grep -E -o "/Volumes/.+$")
	/bin/cp -R "${mounted_path}" ~/Downloads
	/usr/bin/hdiutil detach "${mounted_path}" 1>/dev/null
	/bin/mv -f "${path}" ~/.Trash/
	;;
esac
