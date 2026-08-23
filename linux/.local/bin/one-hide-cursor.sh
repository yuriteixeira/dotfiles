runtimeDir=${XDG_RUNTIME_DIR:-/tmp/one-$UID}
cursorThemeRoot="$runtimeDir/one-cursor-themes"
cursorThemeDir="$cursorThemeRoot/Invisible/cursors"
cursorFile="$cursorThemeDir/left_ptr"

mkdir -p "$cursorThemeDir"
printf '%s' 'WGN1chAAAAAAAAEAAQAAAAIA/f8BAAAAHAAAACQAAAACAP3/AQAAAAEAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAA=' \
  | base64 --decode > "$cursorFile"

for cursorName in \
  default arrow right_ptr hand1 hand2 pointer move text xterm watch wait \
  cross crosshair help progress cell context-menu vertical-text alias copy \
  no-drop not-allowed grab grabbing all-scroll zoom-in zoom-out \
  col-resize row-resize n-resize e-resize s-resize w-resize \
  ne-resize nw-resize se-resize sw-resize ew-resize ns-resize \
  nesw-resize nwse-resize; do
  ln -sf left_ptr "$cursorThemeDir/$cursorName"
done

export XCURSOR_PATH="$cursorThemeRoot"
export XCURSOR_THEME=Invisible
