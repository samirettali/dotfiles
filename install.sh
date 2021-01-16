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

# Utility function to check if a repo already exists, if not then print a
# message and clone it
clone_repo() {
  LOCATION="${1}"
  REPO="${2}"
  REPO_NAME=$(sed 's|^.*/||' <<< "${REPO}")
  if [[ ! -d "${LOCATION}/${REPO_NAME}" ]]; then
    print_message "Cloning ${REPO_NAME} repository"
    mkdir -p "${LOCATION}"
    git -C "${LOCATION}" clone --quiet "${REPO}"
  fi
}

# Change directory to script location
cd $(dirname $0)

# clone_repo "${ZSH_PLUGINS}" https://github.com/wwalker/ssh-find-agent

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

# if hash stack 2>/dev/null; then
#   echo "Haskell detected, compiling zsh-git-prompt..."
#   cd "${HOME}/.zsh/zsh-git-prompt"
#   stack setup
#   stack install
# else
#   echo "Haskell (stack) is not installed, using normal zsh-git-prompt"
# fi
