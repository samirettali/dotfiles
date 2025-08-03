{
  pkgs,
  config,
  lib,
  ...
}: let
  sketchybarExe = lib.getExe config.programs.sketchybar.package;
in
  # TODO: remove this file
  pkgs.writeShellScriptBin "spotify-player-hook" ''
    ${sketchybarExe} --trigger spotify_player_event_hook STATE=$1 ITEM_ID=$2 2>/dev/null || true
  ''
