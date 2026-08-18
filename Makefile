.DEFAULT_GOAL := build
.PHONY: build update clean fmt check models chezmoi

OS := $(shell uname -s)
USERNAME := $(shell whoami)
HOSTNAME := $(shell hostname)
UPDATE_CMD = nix flake update
FMT_CMD = alejandra .
DEADNIX_CMD = deadnix --fail --exclude=machines/xps/hardware-configuration.nix .
STATIX_CMD = statix check .
CHECK_CMD = nix flake check
MODELS_CMD = pi-models --sync --config $(CURDIR)/home/packages/ai/pi-coding-agent/models.json
CHEZMOI_CMD = chezmoi-render $(CURDIR)/chezmoi

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

fmt:
	@echo "Running command: $(FMT_CMD)"
	@$(FMT_CMD)

models:
	@echo "Running command: $(MODELS_CMD)"
	@$(MODELS_CMD)

chezmoi:
	@echo "Running command: $(CHEZMOI_CMD)"
	@$(CHEZMOI_CMD)

check:
	@echo "Running command: $(DEADNIX_CMD)"
	@$(DEADNIX_CMD)
	@echo "Running command: $(STATIX_CMD)"
	@$(STATIX_CMD)
	@echo "Running command: $(CHECK_CMD)"
	@$(CHECK_CMD)
