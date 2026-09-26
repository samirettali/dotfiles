```
sh <(curl -L https://nixos.org/nix/install)
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer ./result/bin/darwin-installer
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

+ Change display dpi
* Disable automatically adjust display brightness
* Disable true tone
