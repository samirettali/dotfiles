#!/usr/bin/env bash

set -euf
set -o pipefail

# Check if git and stow are installed
command -v git >/dev/null 2>&1 || { echo >&2 "git is required, aborting."; exit 1; }
command -v stow >/dev/null 2>&1 || { echo >&2 "stow is required, aborting."; exit 1; }

print_message() {
  GREEN="\033[0;32m"
  NC="\033[0m"
  echo -e "${GREEN}[*]${NC} ${*}"
}

# Change directory to script location
cd $(dirname $0)

OS=$(uname)
modules=()

# Detect the operating system in order to know which dotfiles to install
if [[ "${OS}" = "Darwin" ]]; then
  print_message "MacOS detected"
  modules=("common" "mac")
elif [[ "${OS}" = "Linux" ]]; then
  print_message "Linux detected"
  modules=("common" "linux")
else
  echo "Unsupported OS."
  exit 1
fi

stow -t "${HOME}" stow

git submodule init --quiet
git submodule update --quiet

# Link files with stow and download submodules if any
for module in "${modules[@]}"; do
  print_message "Installing ${module} packages"
  for package in $(find ${module} -maxdepth 1 | grep '/' | sed 's|^.*/||'); do
    print_message "${package}"
    if [[ ! -z $(git submodule status "${module}/${package}") ]]; then
      git submodule update --quiet "${module}/${package}"
    fi
    stow -R -t "${HOME}" -d "${module}" "${package}"
  done
  echo
done

print_message "Done"
