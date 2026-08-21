#!/usr/bin/env bash
#
# shannon-find-nvim: discover the listen socket of an nvim instance running in
# a sibling pane. Prints the socket path on success, exits non-zero with an
# error message on failure.
#
# Replaces the wrapper that ships with the shannon plugin, which delegates to
# shannon's tmux-only bin/find-nvim-socket at a hardcoded pack path. Here the
# primary multiplexer is herdr, so sibling panes come from `herdr pane list`
# (siblings share a tab_id) and the nvim pid from `herdr pane process-info`.
# Outside herdr we fall back to shannon's own implementation, looked up in both
# the vim.pack and the classic pack locations.

set -eu

# --- Fallback --------------------------------------------------------------

# Hand off to shannon's tmux implementation when not running under herdr.
fallback_to_tmux() {
  local candidate
  for candidate in \
    "$HOME/.local/share/nvim/site/pack/core/opt/shannon/bin/find-nvim-socket" \
    "$HOME/.config/nvim/pack/bundle/opt/shannon/bin/find-nvim-socket"
  do
    if [ -x "$candidate" ]; then
      exec "$candidate" "$@"
    fi
  done

  echo "error: not running under herdr, and shannon's find-nvim-socket was not found" >&2
  exit 1
}

# --- Helpers ---------------------------------------------------------------

# Echo the path to nvim's listen socket for `$1`, or fail.
#
# Two complications, both inherited from shannon's implementation:
#
# - The pid in the socket name (`nvim.<pid>.0`) isn't always the pid we
#   identified as nvim: nvim's main process can fork the server, and the
#   socket is named after the child. Callers try child pids too.
#
# - The directory layout differs by platform. On Linux nvim writes the socket
#   directly under `$XDG_RUNTIME_DIR` as `nvim.<pid>.0`. On macOS that is
#   unset, so nvim falls back to `$TMPDIR` but adds a `$USER` namespace and a
#   random subdir, giving `<TMPDIR>/nvim.<USER>/<random>/nvim.<pid>.0`.
socket_for_pid() {
  local pid="$1" base sock
  for base in "${XDG_RUNTIME_DIR:-}" "${TMPDIR:-}" /tmp; do
    [ -z "$base" ] && continue
    for sock in \
      "$base/nvim.${pid}.0" \
      "$base"/nvim."${USER}"/*/nvim."${pid}".0
    do
      if [ -S "$sock" ]; then
        printf '%s\n' "$sock"
        return 0
      fi
    done
  done
  return 1
}

# Echo the pane ids sharing a tab with `$1`, excluding `$1` itself.
sibling_pane_ids() {
  local self="$1" tab
  tab=$(herdr pane get "$self" | jq -er '.result.pane.tab_id') || return 1
  herdr pane list \
    | jq -r --arg tab "$tab" --arg self "$self" \
      '.result.panes[] | select(.tab_id == $tab and .pane_id != $self) | .pane_id'
}

# Echo the pids of nvim processes in the foreground of pane `$1`.
nvim_pids_in_pane() {
  herdr pane process-info --pane "$1" \
    | jq -r '.result.process_info.foreground_processes[]? | select(.name == "nvim") | .pid'
}

# --- Main ------------------------------------------------------------------

main() {
  local self="${HERDR_PANE_ID:-}"
  if [ -z "$self" ]; then
    fallback_to_tmux "$@"
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "error: jq is required to parse herdr output" >&2
    exit 1
  fi

  local pane nvim_pid pid sock found=
  while read -r pane; do
    [ -z "$pane" ] && continue
    while read -r nvim_pid; do
      [ -z "$nvim_pid" ] && continue
      found=1
      for pid in "$nvim_pid" $(pgrep -P "$nvim_pid" 2>/dev/null); do
        if sock=$(socket_for_pid "$pid"); then
          printf '%s\n' "$sock"
          exit 0
        fi
      done
    done < <(nvim_pids_in_pane "$pane")
  done < <(sibling_pane_ids "$self")

  if [ -n "$found" ]; then
    echo "error: found nvim in a sibling herdr pane but no server socket" >&2
  else
    echo "error: no nvim found in sibling herdr panes (tab of $self)" >&2
  fi
  exit 1
}

main "$@"
