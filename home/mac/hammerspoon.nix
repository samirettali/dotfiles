{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.natsukium.hammerspoon
  ];

  home.file = {
    ".hammerspoon/Spoons".source = pkgs.runCommandLocal "hammerspoon-spoons" {} ''
            tmp="$(mktemp -d)"
            cp -R ${inputs.spoons}/Source/. "$tmp"/
            cp -R ${inputs.control-escape-spoon} "$tmp/ControlEscape.spoon"
            chmod -R u+w "$tmp"

            TMP="$tmp" ${pkgs.python3}/bin/python3 - <<'PY'
      import os
      from pathlib import Path

      # EmmyLua writes its generated annotations next to itself, which here is a
      # read-only store path, and the destination lives in a file-local table it
      # never exposes. ~/.hammerspoon is a real directory — home-manager symlinks
      # the files inside it, not the directory — so it can be written to.
      path = Path(os.environ["TMP"]) / "EmmyLua.spoon" / "init.lua"
      text = path.read_text()
      old = """local options = {
        annotations = hs.spoons.resourcePath("annotations"),
        timestampsFilename = hs.spoons.resourcePath("annotations").."/timestamps.json","""
      new = """local options = {
        annotations = hs.configdir .. "/annotations",
        timestampsFilename = hs.configdir .. "/annotations/timestamps.json","""
      assert old in text, "EmmyLua annotations path moved"
      path.write_text(text.replace(old, new))
      PY

            mkdir -p "$out"
            cp -R "$tmp"/. "$out"/
    '';

    # TODO
    # osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:true}' > /dev/null

    ".hammerspoon" = {
      source = ../dotfiles/hammerspoon;
      recursive = true;
    };
    # sketchybar has no built-in event for input source changes, so hammerspoon
    # pushes one: it already owns the layout toggle bound to cmd+ctrl+l
    ".hammerspoon/sketchybar.lua".text =
      lib.optionalString config.programs.sketchybar.enable
      /*
      lua
      */
      ''
        local sketchybar = "${lib.getExe config.programs.sketchybar.package}"

        local function push()
            hs.task
                .new(sketchybar, nil, {
                    "--trigger",
                    "keyboard_layout_change",
                    "SOURCE_ID=" .. (hs.keycodes.currentSourceID() or ""),
                })
                :start()
        end

        hs.keycodes.inputSourceChanged(push)
        push()
      '';

    # Lets the plain lua files branch on what nix decided, without them having
    # to be rendered themselves.
    ".hammerspoon/features.lua".text =
      /*
      lua
      */
      ''
        return {
            aerospace = ${lib.boolToString config.programs.aerospace.enable},
        }
      '';
  };
}
