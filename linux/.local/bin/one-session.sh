scriptDir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

scale=${SCALE:-2}
app=${1:-foot}
outputs=$(wlr-randr)

externalDisplayName='Dell Inc. DELL U3219Q B26R413'
externalOutput=$(
  printf '%s\n' "$outputs" |
    awk -v displayName="$externalDisplayName" '/^[^[:space:]]/ && index($0, displayName) { print $1; exit }'
)

if [ -n "$externalOutput" ]; then
  output=$externalOutput
else
  output=eDP-1
fi

echo ">>> Output: $output"
wlr-randr --output "$output" --on --preferred --scale "$scale" || exit 1

for otherOutput in $(printf '%s\n' "$outputs" | awk '/^[^[:space:]]/{print $1}'); do
  [ "$otherOutput" = "$output" ] || wlr-randr --output "$otherOutput" --off || exit 1
done

### Helper

wlsunset -S 07:30 -s 20:00 -t 3500 -T 6500 &
sunsetPid=$!

swayidle ... &
idlePid=$!

### Cleanup

cleanup() {
kill "$sunsetPid" "$idlePid" 2>/dev/null
wait "$sunsetPid" "$idlePid" 2>/dev/null
}
trap cleanup EXIT INT TERM HUP

### Start app

[ "$app" = 'foot' ] || [ "$app" = 'alacritty' ] && . "$scriptDir/one-hide-cursor.sh"

"$app"

