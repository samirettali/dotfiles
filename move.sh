#!/bin/bash

# Script to move tmux panes or windows to another session using fzf in a floating window.

# Ensure we are in a tmux session
if [ -z "$TMUX" ]; then
  tmux display-message "Error: This script must be run from within a tmux session."
  exit 1
fi

# Get the current session, window, and pane details
CURRENT_SESSION_NAME=$(tmux display-message -p '#S')
CURRENT_WINDOW_ID=$(tmux display-message -p '#{window_id}') # e.g., @1
CURRENT_PANE_ID=$(tmux display-message -p '#D')          # e.g., %1

# Get a list of other sessions (name and ID for robustness if names aren't unique, though we'll use name for display)
# Format: session_name<TAB>session_id
OTHER_SESSIONS_RAW=$(tmux list-sessions -F "#{session_name}#{?session_attached,(attached),} #{session_windows} windows#{T মনুষsession_activity} #{session_id}" | grep -v "^${CURRENT_SESSION_NAME}")
OTHER_SESSIONS_FOR_FZF=$(tmux list-sessions -F "#{session_name}#{?session_attached, (attached),} [#W windows]" | grep -v "^${CURRENT_SESSION_NAME}")


if [ -z "$OTHER_SESSIONS_FOR_FZF" ]; then
  tmux display-message "No other tmux sessions available to move to."
  exit 1
fi

# Define the command to be run inside the tmux popup
# It will take the list of other sessions as $1
POPUP_COMMAND="
  # \$1 contains the session list for fzf
  # Select target session
  TARGET_SESSION_LINE=\$(echo -e \"\$1\" | fzf --height 50% --reverse --border=rounded --margin=1 --padding=1 --prompt=\"🎯 Target Session: \" --header=\"Select session to move to\")
  if [ -z \"\$TARGET_SESSION_LINE\" ]; then
    echo \"cancel_session\" # Output to indicate cancellation at session selection
    echo \"\"
    exit 0
  fi
  # Extract just the session name (assuming format 'name ....')
  TARGET_SESSION_NAME=\$(echo \"\$TARGET_SESSION_LINE\" | awk '{print \$1}')

  # Select action
  ACTION_CHOICE=\$(printf \"Current Pane\\nCurrent Window\\nCancel\" | fzf --height 30% --reverse --border=rounded --margin=1 --padding=1 --prompt=\"➡️ Action: \" --header=\"Choose what to move\")
  if [ -z \"\$ACTION_CHOICE\" ] || [ \"\$ACTION_CHOICE\" = \"Cancel\" ]; then
    echo \"\$TARGET_SESSION_NAME\" # Still output session name
    echo \"cancel_action\"        # Output to indicate cancellation at action selection
    exit 0
  fi

  echo \"\$TARGET_SESSION_NAME\"
  echo \"\$ACTION_CHOICE\"
"

# Execute the popup command and capture its output
# The popup takes OTHER_SESSIONS_FOR_FZF as the first argument ($1 in POPUP_COMMAND)
# -w80% -h50% are width and height of the popup
POPUP_RAW_OUTPUT=$(tmux popup -w80% -h60% -E -- sh -c "$POPUP_COMMAND" tmux-move-popup "${OTHER_SESSIONS_FOR_FZF}")

# Parse the output from the popup
# Output is two lines: TARGET_SESSION_NAME and ACTION_CHOICE
TARGET_SESSION_NAME_FROM_POPUP=$(echo "$POPUP_RAW_OUTPUT" | sed -n '1p')
ACTION_CHOICE_FROM_POPUP=$(echo "$POPUP_RAW_OUTPUT" | sed -n '2p')

# Handle cancellation
if [ "$TARGET_SESSION_NAME_FROM_POPUP" = "cancel_session" ] || \
   [ "$ACTION_CHOICE_FROM_POPUP" = "cancel_action" ] || \
   [ -z "$TARGET_SESSION_NAME_FROM_POPUP" ] || \
   [ -z "$ACTION_CHOICE_FROM_POPUP" ]; then
  tmux display-message "Move operation cancelled."
  exit 0
fi

# Proceed with the move operation
case $ACTION_CHOICE_FROM_POPUP in
  "Current Pane")
    # Find an existing window in the target session or create a new one.
    TARGET_WINDOW_CANDIDATE_ID=$(tmux list-windows -t "$TARGET_SESSION_NAME_FROM_POPUP" -F "#{window_id}" | head -n 1)

    if [ -z "$TARGET_WINDOW_CANDIDATE_ID" ]; then
      # No windows in target session, create one.
      # new-window -d (don't select) -P (print info) -F '#{window_id}' (format) -t <target-session>: (append to session)
      ACTUAL_TARGET_WINDOW_ID=$(tmux new-window -d -P -F '#{window_id}' -t "$TARGET_SESSION_NAME_FROM_POPUP:")
      tmux display-message "Created new window ($ACTUAL_TARGET_WINDOW_ID) in session '$TARGET_SESSION_NAME_FROM_POPUP'."
    else
      ACTUAL_TARGET_WINDOW_ID=$TARGET_WINDOW_CANDIDATE_ID
    fi
    # Move the pane. tmux will place it in the target window.
    if tmux move-pane -s "$CURRENT_PANE_ID" -t "$ACTUAL_TARGET_WINDOW_ID"; then
      tmux display-message "Moved pane $CURRENT_PANE_ID to window $ACTUAL_TARGET_WINDOW_ID in session '$TARGET_SESSION_NAME_FROM_POPUP'."
    else
      tmux display-message "Error moving pane $CURRENT_PANE_ID."
    fi
    ;;

  "Current Window")
    # Find the next available window index in the target session to avoid collisions.
    # Or simply let tmux decide, or move to a specific high number index.
    # For simplicity, tmux will typically add it at the next available index or re-index.
    # Using -t <session_name>: ensures it goes to that session, tmux handles index.
    if tmux move-window -s "$CURRENT_WINDOW_ID" -t "$TARGET_SESSION_NAME_FROM_POPUP:"; then
      tmux display-message "Moved window (originally $CURRENT_WINDOW_ID) to session '$TARGET_SESSION_NAME_FROM_POPUP'."
    else
      # If the source window was the last in its session, that session might close.
      # Check if current session still exists, otherwise message might fail.
      if tmux has-session -t "$CURRENT_SESSION_NAME" 2>/dev/null; then
         tmux display-message -t "$CURRENT_SESSION_NAME" "Error moving window (originally $CURRENT_WINDOW_ID)."
      else # if current session closed, display in target or globally
         tmux display-message "Error moving window (originally $CURRENT_WINDOW_ID). Current session may have closed."
      fi
    fi
    ;;
esac

exit 0
