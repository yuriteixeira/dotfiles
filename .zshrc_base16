### Base16 Colors 
source $HOME/.config/base16-shell/base16-shell.plugin.zsh

## Random favorite selector
function b16r {
  eval $(sort -R ~/.base16_favorites | head -n1 | sed 's/base16-//g' | xargs -I {} echo base16_{})
  echo ""
  echo ">>> Random favorite theme is now: $BASE16_THEME"
  echo ""
}

## Interactive theme selector for Base16
function b16 {
  local scriptsDir="$HOME/.config/base16-shell/scripts"
  local currentThemeFile="$HOME/.base16_theme"
  local historyFile="$HOME/.b16-history"
  
  if [ ! -d "$scriptsDir" ]; then
    echo "ERROR: Base16 scripts directory not found at $scriptsDir"
    return 1
  fi
  
  # List all available themes, bypassing any ls aliases (like eza --hyperlink)
  local themes=$(command ls -1 "$scriptsDir" \
    | grep '^base16-.*\.sh$' \
    | sed 's/^base16-//;s/\.sh$//' \
    | sort)
  
  # Find the position of the current theme in the list (1-indexed)
  local themePos=$(echo "$themes" | grep -nE "^${BASE16_THEME:-}$" | cut -d: -f1)
  themePos=${themePos:-1}
  
  local selectedTheme=$(echo "$themes" \
    | fzf \
        --sync \
        --header "Base16 Themes: ↕ preview, ENTER select, <Esc> cancel" \
        --layout=reverse \
        --height=40% \
        --preview-window=hidden \
        --history="$historyFile" \
        --bind "start:pos($themePos)" \
        --bind "focus:execute-silent(. $scriptsDir/base16-{}.sh > /dev/tty)"
  )
  
  if [ -n "$selectedTheme" ]; then
    eval "base16_$selectedTheme"
    echo "Base16 theme set to: $selectedTheme"
  else
    if [ -f "$currentThemeFile" ]; then
      . $currentThemeFile
      echo "Base16 theme restored to original ($BASE16_THEME)"
    fi
  fi
}

## Add current theme to base16 favorites
function b16a {
  if [ -z "$BASE16_THEME" ]; then
    echo "ERROR: No Base16 theme currently active (\$BASE16_THEME is empty)."
    return 1
  fi

  local favoritesFile="$HOME/.base16_favorites"
  
  # Ensure the file exists
  touch "$favoritesFile"
  
  # Check if already in favorites (exact match)
  if grep -qx "$BASE16_THEME" "$favoritesFile"; then
    echo "Theme '$BASE16_THEME' is already in your favorites."
  else
    echo "$BASE16_THEME" >> "$favoritesFile"
    # Clean up: sort and unique
    sort -u -o "$favoritesFile" "$favoritesFile"
    echo "Added '$BASE16_THEME' to favorites."
  fi
}
