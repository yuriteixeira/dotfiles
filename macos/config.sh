ln -sf "$PWD/.config/karabiner" $HOME/.config
ln -sf "$PWD/.config/aerospace" $HOME/.config
ln -sf "$PWD/.config/borders" $HOME/.config
ln -sf "$PWD/.config/alfred/" $HOME/.config
ln -sf "$PWD/.config/alacritty" $HOME/.config

defaults write -g ApplePressAndHoldEnabled -bool false 

# Disable emoji suggestions (https://apple.stackexchange.com/questions/465132/how-do-i-turn-off-macos-sonomas-emoji-guessing)
sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist emoji_enhancements -dict-add Enabled -bool NO

