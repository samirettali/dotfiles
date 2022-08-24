#!/usr/bin/env bash

set -euf
set -o pipefail

check_installed() {
  command -v "${1}" >/dev/null 2>&1 || { echo >&2 "${1} is required, aborting."; exit 1; }
}

# Check if git and stow are installed
check_installed git
check_installed stow

print_message() {
  GREEN="\033[0;32m"
  NC="\033[0m"
  echo -e "${GREEN}[*]${NC} ${*}"
}

# Change directory to script location
cd "$(dirname $0)"

OS=$(uname)
modules=()

# Detect the operating system in order to know which dotfiles to install
if [[ "${OS}" = "Darwin" ]]; then
  print_message "MacOS detected"
  modules=("common" "mac")
elif [[ "${OS}" = "Linux" ]]; then
  print_message "Linux detected"
  modules=("common" "linux" "linux-root")
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
    if [[ "${module}" == "*-root" ]]; then
      sudo stow -R -t "/" -d "${module}" "${package}"
    else
      stow -R -t "${HOME}" -d "${module}" "${package}"
    fi
  done
  echo
done

print_message "Done"
