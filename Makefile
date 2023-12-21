ACTIVATION_HOST ?= $(shell uname -s)

.PHONY: switch
switch:
	nix run . -- switch --flake .#"${ACTIVATION_HOST}"

.PHONY: build
build:
	nix run . -- build --flake .#"${ACTIVATION_HOST}"

.PHONY: install-nix
install-nix:
	curl -L https://nixos.org/nix/install | sh

.PHONY: install-brew
install-brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
