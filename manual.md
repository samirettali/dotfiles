```
sh <(curl -L https://nixos.org/nix/install)
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer ./result/bin/darwin-installer
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

+ Change display dpi
* Disable display dim on battery
* Disable automatically adjust display brightness
* Keyboard layout
* Disable true tone
* `echo host.docker.internal | sudo tee -a /etc/hosts`
* Set fish as default shell
* Disable low power mode on battery
