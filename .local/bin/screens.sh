#!/bin/sh
# Screen power control for the dwl keybindings.
#   off -> DPMS-blank all outputs   |   on -> wake them, then reapply wallpaper
# Uses wlopm, not `wlr-randr --off/--on`: dwl's DPMS path only toggles each
# output's enabled flag without re-adding it to the layout, so monitor order
# survives. wlr-randr re-adds outputs and reshuffles them.

case "$1" in
	off)
		wlopm --off '*'
		;;
	on)
		wlopm --on '*'
		# awww can drop surfaces across the power cycle; reapply (cached, instant).
		awww img "$HOME/.cache/wallpaper.jpg"
		;;
	*)
		echo "usage: $0 {on|off}" >&2
		exit 1
		;;
esac
