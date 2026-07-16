#!/bin/sh
# Generic display auto-config — no hard-coded output names, so it works on any
# machine (or a fresh clone) with zero setup.
#   - Prefer externals: if any is present, enable externals and switch off
#     internal panels (detected by connector prefix eDP*/LVDS*/DSI*).
#   - Lay active outputs out gapless, left-to-right, sorted by connector name, at
#     preferred mode, in one wlr-randr call -> same layout every login (dwl's own
#     auto-placement varies by enumeration order).
# Rotation/scaling/custom order are per-machine: put them in ~/.config/kanshi/config
# (untracked), which runs after this and overrides it.

json=$(wlr-randr --json 2>/dev/null) || exit 0
names=$(printf '%s' "$json" | jq -r '.[].name')
[ -n "$names" ] || exit 0

# Externals (non-internal connectors) are preferred when present.
externals=$(printf '%s\n' "$names" | grep -Ev '^(eDP|LVDS|DSI)' | sort | tr '\n' ' ')
if [ -n "$externals" ]; then
	active=$externals
else
	active=$(printf '%s\n' "$names" | sort | tr '\n' ' ')
fi

# One atomic wlr-randr invocation: active outputs on + gapless; the rest off.
args=""
x=0
for name in $active; do
	w=$(printf '%s' "$json" | jq -r --arg n "$name" '
		.[] | select(.name==$n)
		| ( [.modes[] | select(.preferred)][0].width
		    // [.modes[] | select(.current)][0].width
		    // 0 )')
	args="$args --output $name --on --preferred --pos ${x},0"
	x=$((x + w))
done
for name in $names; do
	case " $active " in
		*" $name "*) : ;;                       # active -> already turned on
		*) args="$args --output $name --off" ;; # inactive -> turn off
	esac
done

# shellcheck disable=SC2086
wlr-randr $args
