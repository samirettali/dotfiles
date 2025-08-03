.DEFAULT_GOAL := build

# TODO:
# sudo nix-channel --update
# nix flake update
# sudo nixos-rebuild switch --flake ~/dev/dotfiles/#xps

OS := $(shell uname -s)
USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)
UPDATE_CMD = nix flake update

ifeq ($(OS),Linux)
    ifneq ($(wildcard /etc/NIXOS),)
        REBUILD_CMD = sudo nixos-rebuild switch --flake .\#$(HOSTNAME)
		CLEAN_CMD = sudo nix-collect-garbage --delete-old
    else
        REBUILD_CMD = nix run --flake .\#$(HOSTNAME)
		CLEAN_CMD = nix-collect-garbage --delete-old
    endif
endif

ifeq ($(OS),Darwin)
    REBUILD_CMD = nh darwin switch .
	CLEAN_CMD = nix-collect-garbage --delete-old
endif

update:
	@echo "Running command: $(UPDATE_CMD)"
	@$(UPDATE_CMD)

build:
	@echo "Running command: $(REBUILD_CMD)"
	@$(REBUILD_CMD)

clean:
	@echo "Running command: $(CLEAN_CMD)"
	@$(CLEAN_CMD)
