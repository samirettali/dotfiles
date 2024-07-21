.DEFAULT_GOAL := build

# TODO:
# sudo nix-channel --update
# nix flake update
# sudo nixos-rebuild switch --flake ~/dev/dotfiles/#xps

OS := $(shell uname -s)
HOSTNAME := $(shell hostname)

ifeq ($(OS),Linux)
    ifneq ($(wildcard /etc/NIXOS),)
        REBUILD_CMD = sudo nixos-rebuild switch --flake .\#$(HOSTNAME)
		CLEANUP_CMD = sudo nix-collect-garbage --delete-old
    else
        REBUILD_CMD = nix run --flake .\#$(HOSTNAME)
		CLEANUP_CMD = nix-collect-garbage --delete-old
    endif
endif

ifeq ($(OS),Darwin)
    REBUILD_CMD = darwin-rebuild switch --flake .\#$(HOSTNAME)
	CLEANUP_CMD = nix-collect-garbage --delete-old
endif

build:
	@echo "Running command: $(REBUILD_CMD)"
	@$(REBUILD_CMD)

cleanup:
	@echo "Running command: $(CLEANUP_CMD)"
	@$(CLEANUP_CMD)
