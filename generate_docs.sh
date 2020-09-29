#!/bin/sh

# https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md

for f in ~/.hammerspoon/Spoons/*/init.lua; do
	echo "#" "$(basename "$(dirname "${f}")")"

done
