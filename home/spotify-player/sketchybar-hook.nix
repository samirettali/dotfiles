{
  pkgs,
  config,
  lib,
  ...
}: let
  jqExe = lib.getExe pkgs.jq;
  spotifyPlayerExe = lib.getExe config.programs.spotify-player.package;
  sketchybarExe = lib.getExe config.programs.sketchybar.package;
in
  pkgs.writeShellScriptBin "spotify-player-hook" ''
    get_text() {
        if [[ "$1" =~ ^spotify:track: ]]; then
            track_id="''${1#spotify:track:}"

            data=$(${spotifyPlayerExe} get item track --id "''${track_id}")

            if [ -z "$data" ]; then
                echo "Unknown Track"
                return
            fi

            echo "$data" | ${jqExe} -r '.name + " - " + (.album.name)'
        fi
    }

    update_sketchybar() {
        local label="$1"
        if [ -z "$label" ]; then
            ${sketchybarExe} --set music drawing=off
        else
            ${sketchybarExe} --set music label="$label" drawing=on
        fi
    }

    symbol=""
    label=""

    case "$1" in
    "Changed")
        symbol="" # TODO: what is this event?
        label=$(get_text "$2")
        ;;
    "Playing")
        symbol=""
        label=$(get_text "$2")
        ;;
    "Paused")
        symbol=""
        label=$(get_text "$2")
        ;;
    "EndOfTrack")
        symbol=""
        label=$(get_text "$2")
        ;;
    esac
    update_sketchybar "''${symbol} ''${label}"
  ''
