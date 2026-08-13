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
* Add the andromeda remote, for pushing dotfiles there without going through
  GitHub: `git remote add andromeda samir@andromeda:/home/samir/dev/dotfiles`.
  The port and the key come from the `andromeda` block in `~/.ssh/config`.
  `make site` in `selfhosted` pushes on its own and does not need this remote;
  it is here for the out-of-band push, followed by
  `ssh andromeda 'cd ~/dev/dotfiles && $(nix build --no-link --print-out-paths .#homeConfigurations.andromeda.activationPackage)/activate'`
