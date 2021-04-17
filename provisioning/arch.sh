sudo timedatectl set-ntp true
sudo timedatectl set-timezone Europe/Rome
sudo pacman -S lxappearance
sudo pacman -S interception-caps2esc
sudo pacman -S interception-dual-function-keys
sudo pacman -S sshfs
sudo pacman -S ranger
sudo pacman -S openvpn
sudo pacman -S xorg-xev
sudo pacman -S docker-compose

# sway
sudo pacman -S sway swayidle swaylock waybar xorg-xwaylaind qt5-wayland rofi

# Sway launcher
sudo pacman -S bemenu
yay -S j4-dmenu-desktop-git
yay -S espanso
# sudo pacman -S xorg-mkfontscale
yay -S nerd-fonts-source-code-pro
sudo pacman -S fd # change alias

sudo usermod -aG wireshark samir
# Add /etc/X11/xorg.conf.d/30-touchpad.conf to dotfiles
