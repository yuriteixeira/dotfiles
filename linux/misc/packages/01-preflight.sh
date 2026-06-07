set -ex
originalDir=$PWD

cd ~
rm -rf yay-bin
sudo pacman -S --noconfirm --needed git base-devel   
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm

yay --version

cd $originalDir
