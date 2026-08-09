{
  config,
  inputs,
  lib,
  nurPkgs,
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

      path = Path(os.environ["TMP"]) / "RecursiveBinder.spoon" / "init.lua"
      text = path.read_text()
      old = """      if string.len(newEntry) > obj.helperEntryLengthInChar then
               newEntry = string.sub(newEntry, 1, obj.helperEntryLengthInChar - 2)..'..'
            elseif string.len(newEntry) < obj.helperEntryLengthInChar then
               newEntry = newEntry..string.rep(' ', obj.helperEntryLengthInChar - string.len(newEntry))
            end
      """
      new = """      if obj.helperEntryLengthInChar > 0 and string.len(newEntry) > obj.helperEntryLengthInChar then
               newEntry = string.sub(newEntry, 1, obj.helperEntryLengthInChar - 2)..'..'
            elseif obj.helperEntryLengthInChar > 0 and string.len(newEntry) < obj.helperEntryLengthInChar then
               newEntry = newEntry..string.rep(' ', obj.helperEntryLengthInChar - string.len(newEntry))
            end
      """
      path.write_text(text.replace(old, new))

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

    # rbw's agent keeps the vault key in memory, so every call after the first
    # unlock is instant enough to sit behind a hotkey
    ".hammerspoon/rbw.lua".text =
      lib.optionalString config.programs.rbw.enable
      /*
      lua
      */
      ''
        local canvas = require("canvas")
        local frecency = require("frecency")
        local task = require("task")

        local rbw = "${lib.getExe config.programs.rbw.package}"

        local CLEAR_AFTER = 30

        local M = {}

        local uses = frecency.new("rbw.uses")

        local function run(args, done)
            task.run(rbw, args, done, function(message)
                hs.alert.show("rbw: " .. message)
            end)
        end

        -- ConcealedType keeps the secret out of clipboard managers, and the
        -- changeCount guard makes the timer a no-op if anything else was
        -- copied in the meantime
        local function copy(secret, label)
            hs.pasteboard.writeAllData({
                ["public.utf8-plain-text"] = secret,
                ["org.nspasteboard.ConcealedType"] = secret,
            })

            local stamp = hs.pasteboard.changeCount()

            hs.timer.doAfter(CLEAR_AFTER, function()
                if hs.pasteboard.changeCount() == stamp then
                    hs.pasteboard.clearContents()
                end
            end)

            hs.alert.show(label .. " copied, cleared in " .. CLEAR_AFTER .. "s")
        end

        local function subText(entry)
            local parts = {}

            if entry.user and entry.user ~= "" then
                table.insert(parts, entry.user)
            end

            if entry.folder and entry.folder ~= "" then
                table.insert(parts, entry.folder)
            end

            return table.concat(parts, " · ")
        end

        local function pick(action)
            return function()
                run({ "list", "--raw" }, function(stdout)
                    local entries = hs.json.decode(stdout)

                    if not entries then
                        hs.alert.show("rbw: could not parse the vault")
                        return
                    end

                    local score = uses.scores()
                    local choices = {}

                    for _, entry in ipairs(entries) do
                        if entry["type"] == "Login" then
                            table.insert(choices, {
                                ["text"] = entry.name,
                                ["subText"] = subText(entry),
                                ["uuid"] = entry.id,
                                ["boost"] = score(entry.id),
                            })
                        end
                    end

                    if #choices == 0 then
                        hs.alert.show("rbw: no logins in the vault")
                        return
                    end

                    canvas.picker({
                        prompt = "vault",
                        choices = choices,
                        onSelect = function(choice)
                            uses.remember(choice.uuid)
                            action(choice.uuid)
                        end,
                    })

                    -- the picker reads the local db and the agent only syncs
                    -- every sync_interval (an hour), so an entry added from the
                    -- browser would not show up until then; refresh behind the
                    -- picker so the next invocation has it
                    run({ "sync" }, function() end)
                end)

                return true
            end
        end

        M.password = pick(function(id)
            run({ "get", id }, function(secret)
                copy(secret, "password")
            end)
        end)

        -- many native clients and installers refuse a paste, so type it instead;
        -- the delay lets the picker's keyDown tap fully stop, otherwise it can
        -- swallow the synthetic events we are about to post
        M.type_password = pick(function(id)
            run({ "get", id }, function(secret)
                hs.timer.doAfter(0.2, function()
                    hs.eventtap.keyStrokes(secret)
                end)
            end)
        end)

        M.username = pick(function(id)
            run({ "get", "--field", "username", id }, function(user)
                copy(user, "username")
            end)
        end)

        M.code = pick(function(id)
            run({ "code", id }, function(code)
                copy(code, "code")
            end)
        end)

        return M
      '';

    # `playlist list` reads the sqlite cache without touching the network (~5ms
    # against ~1.1s for the three API pages), and refreshes behind the picker
    ".hammerspoon/spotctl.lua".text =
      /*
      lua
      */
      ''
        local canvas = require("canvas")
        local frecency = require("frecency")
        local task = require("task")

        local spotctl = "${lib.getExe nurPkgs.spotctl}"

        local M = {}

        local uses = frecency.new("spotctl.uses")

        -- every spotctl command answers in JSON, errors included
        local function reason(text)
            local decoded = hs.json.decode(text)

            if decoded and decoded.error then
                return decoded.error
            end

            return text
        end

        local function run(args, done)
            task.run(spotctl, args, done, function(message)
                hs.alert.show("spotctl: " .. reason(message))
            end)
        end

        -- reached with tab from the playlist picker: reads the cached items of
        -- that one playlist, so it costs no network either
        local function pickTrack(playlistID, playlistName)
            run({ "playlist", "items", playlistID }, function(stdout)
                local result = hs.json.decode(stdout)

                if not result or not result.items then
                    hs.alert.show("spotctl: could not read the playlist tracks")
                    return
                end

                local choices = {}

                for _, track in ipairs(result.items) do
                    table.insert(choices, {
                        ["text"] = track.name,
                        ["subText"] = table.concat(track.artists or {}, ", "),
                        ["uuid"] = track.id,
                    })
                end

                if #choices == 0 then
                    hs.alert.show("spotctl: no cached tracks for " .. playlistName)
                    return
                end

                canvas.picker({
                    prompt = playlistName,
                    choices = choices,
                    onSelect = function(choice)
                        run({ "play", "track", choice.uuid })
                    end,
                })
            end)
        end

        function M.play_playlist()
            run({ "playlist", "list" }, function(stdout)
                local result = hs.json.decode(stdout)

                if not result or not result.items then
                    hs.alert.show("spotctl: could not read the playlist cache")
                    return
                end

                local score = uses.scores()
                local choices = {}

                for _, playlist in ipairs(result.items) do
                    table.insert(choices, {
                        ["text"] = playlist.name,
                        ["subText"] = playlist.tracks .. " tracks",
                        ["uuid"] = playlist.id,
                        ["boost"] = score(playlist.id),
                    })
                end

                if #choices == 0 then
                    hs.alert.show("spotctl: no playlists cached")
                    return
                end

                canvas.picker({
                    prompt = "playlist",
                    choices = choices,
                    onSelect = function(choice)
                        uses.remember(choice.uuid)
                        run({ "play", "playlist", choice.uuid })
                    end,
                    onAlternate = function(choice)
                        pickTrack(choice.uuid, choice.text)
                    end,
                })

                -- the read never checks freshness, by design, so refresh behind
                -- the picker: this run stays instant, the next one is current
                run({ "playlist", "list", "--refresh" })
            end)

            return true
        end

        return M
      '';
  };
}
