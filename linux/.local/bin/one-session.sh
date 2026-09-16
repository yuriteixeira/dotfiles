### Output setup

if ! command -v wlr-randr >/dev/null 2>&1
then
  echo ">>> Error: wlr-randr is required" >&2
  exit 1
fi

if [ -n "$SCALE" ]
then
  scale="${SCALE}"
else
  [ "$(uname -n)" == "yuri-x201" ] && scale="1" || scale="2";
fi

echo ">>> Scale: ${scale}"

app=${1:-foot}

# Look through the wlr-randr output for an unindented line containing this Dell monitor name.
# Print the first word from that line, which is the monitor’s output identifier, and stop searching.
outputs=$(wlr-randr)
externalDisplayName='Dell Inc. DELL U3219Q B26R413'
externalOutput=$(
  printf '%s\n' "$outputs" |
    awk -v displayName="$externalDisplayName" '/^[^[:space:]]/ && index($0, displayName) { print $1; exit }'
)

if [ -n "$externalOutput" ]; then
  output=$externalOutput
else
  output=$(wlr-randr | awk  '{ print $1; exit }')
fi

echo ">>> Output: $output"

wlr-randr --output "$output" --on --preferred --scale "$scale" || exit 1

# Only one output will be enabled
for otherOutput in $(printf '%s\n' "$outputs" | awk '/^[^[:space:]]/{print $1}'); do
  [ "$otherOutput" = "$output" ] || wlr-randr --output "$otherOutput" --off || exit 1
done

### Helpers

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

"$app"

