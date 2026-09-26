.DEFAULT_GOAL := build
.PHONY: build update clean fmt check check-ci check-fmt check-lint check-tests check-pi check-herdr check-eval check-eval-mbp check-eval-andromeda check-chezmoi models chezmoi
.NOTPARALLEL: check check-ci

OS := $(shell uname -s)
HOSTNAME := $(shell hostname -s)
UPDATE_CMD = nix flake update
MODELS_CMD = pi-models --sync --config $(CURDIR)/home/packages/ai/pi-coding-agent/models.json
CHEZMOI_CMD = bash $(CURDIR)/home/dotfiles/scripts/chezmoi-render.sh

ifeq ($(OS),Linux)
    ifneq ($(wildcard /etc/NIXOS),)
        REBUILD_CMD = sudo nixos-rebuild switch --flake .\#$(HOSTNAME)
        CLEAN_CMD = sudo nix-collect-garbage --delete-old
    else
        REBUILD_CMD = activation="$$(nix build --no-link --print-out-paths '.\#homeConfigurations.$(HOSTNAME).activationPackage')" && HOME_MANAGER_BACKUP_EXT=bak HOME_MANAGER_BACKUP_OVERWRITE=1 "$$activation/activate"
        CLEAN_CMD = nix-collect-garbage --delete-old
    endif
endif

ifeq ($(OS),Darwin)
    REBUILD_CMD = nh darwin switch .
    CLEAN_CMD = nix-collect-garbage --delete-old
endif

update:
	@$(UPDATE_CMD)

build:
	@$(REBUILD_CMD)

clean:
	@$(CLEAN_CMD)

fmt:
	@bash scripts/check-nix.sh fmt

models:
	@$(MODELS_CMD)

chezmoi:
	@$(CHEZMOI_CMD) "$(CURDIR)/chezmoi" "$(CURDIR)"

check: check-ci check-pi check-herdr check-eval check-chezmoi

check-ci: check-fmt check-lint check-tests

check-fmt:
	@bash scripts/check-nix.sh fmt-check

check-lint:
	@bash scripts/check-nix.sh lint

check-tests:
	@node --test tests/config.test.mjs tests/check-nix.test.mjs tests/js-profile.test.mjs
	@BROWSER_BIN= node --test home/packages/ai/skills/web-browser/browser.test.mjs

check-pi:
	@nix develop --no-write-lock-file --command bash -eu -c \
		'tsc --project home/packages/ai/pi-coding-agent/tsconfig.json; node --test tests/x-search.test.mjs'

check-herdr:
	@set -eu; HERDR_SOURCE=$$(nix eval --impure --raw --expr '(builtins.getFlake (toString ./.)).inputs.herdr-fork.outPath'); export HERDR_SOURCE; \
	node --test tests/herdr-integrations.test.mjs; \
	env -u HERDR_ENV -u HERDR_SOCKET_PATH -u HERDR_PANE_ID bun test "$$HERDR_SOURCE/src/integration/assets/herdr-agent-state.test.ts"

check-eval: check-eval-mbp check-eval-andromeda

check-eval-mbp:
	@nix eval --no-write-lock-file --raw .\#darwinConfigurations.mbp.system.drvPath
	@printf '\n'

check-eval-andromeda:
	@nix eval --no-write-lock-file --raw .\#homeConfigurations.andromeda.activationPackage.drvPath
	@printf '\n'

check-chezmoi:
	@set -eu; tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT; \
	cp -R chezmoi/. "$$tmp/"; \
	$(CHEZMOI_CMD) "$$tmp" "$(CURDIR)" && diff -ru chezmoi "$$tmp"
