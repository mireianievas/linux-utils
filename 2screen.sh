#!/bin/sh

# Based on
# https://bbs.archlinux.org/viewtopic.php?id=191555
# https://bitbucket.org/denilsonsa/small_scripts/src/default/screenlayout/create-virtual-modelines.sh?fileviewer=file-view-default

add_modeline() {
	local modeline name
	modeline="$(gtf "$2" "$3" "$4" | sed -n 's/.*Modeline "\([^" ]\+\)" \(.*\)/\1 \2/p')"
	name="$(echo "${modeline}" | sed 's/\([^ ]\+\) .*/\1/')"
	if [ -z "${modeline}" -o -z "${name}" ] ; then
		echo "Error! modeline='${modeline}' name='${name}'"
		exit 1
	fi
	xrandr --delmode "$1" "${name}"
	xrandr --rmmode "${name}"
	xrandr --newmode ${modeline}
	xrandr --addmode "$1" "${name}"
}

add_modeline VIRTUAL1 960 540 60
add_modeline VIRTUAL1 1280 768 60
add_modeline VIRTUAL1 1920 1080 60
add_modeline VIRTUAL1 1920 1200 60
add_modeline VIRTUAL1 960 600 60
add_modeline VIRTUAL1 800 480 60
add_modeline VIRTUAL1 640 400 60
add_modeline VIRTUAL1 640 360 60

dconf write /org/gnome/settings-daemon/plugins/media-keys/video-out ''
dconf write /org/gnome/settings-daemon/plugins/media-keys/screenshot ''
dconf write /org/gnome/settings-daemon/plugins/xrandr/active false
#dconf write /org/gnome/settings-daemon/plugins/media-keys/active false


xrandr --output eDP1 --auto --primary --output VIRTUAL1 --auto --secondary --left-of eDP1

x11vnc -clip xinerama1
