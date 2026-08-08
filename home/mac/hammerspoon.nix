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

    # rbw's agent keeps the vault key in memory, so every call after the first
    # unlock is instant enough to sit behind a hotkey
    ".hammerspoon/rbw.lua".text =
      lib.optionalString config.programs.rbw.enable
      /*
      lua
      */
      ''
        local canvas = require("canvas")

        local rbw = "${lib.getExe config.programs.rbw.package}"

        local CLEAR_AFTER = 30

        local M = {}

        -- hs.task is userdata with a __gc: dropping the only reference lets it
        -- be collected mid-flight, so it has to be held onto
        local running = {}

        -- Without a stream callback hs.task only drains the pipe once the
        -- process has exited, so anything over the 64k pipe buffer deadlocks:
        -- the child blocks in write() and never terminates. A vault dump is
        -- well past that, hence the streaming reader.
        local function run(args, done)
            local task
            local out, err = {}, {}
            local exitCode = nil
            local delivered = false

            local function collect(stdout, stderr)
                if stdout and stdout ~= "" then
                    table.insert(out, stdout)
                end

                if stderr and stderr ~= "" then
                    table.insert(err, stderr)
                end
            end

            local function deliver()
                if delivered or exitCode == nil then
                    return
                end

                delivered = true
                running[task] = nil

                if exitCode ~= 0 then
                    hs.alert.show("rbw: " .. (table.concat(err):gsub("%s+$", "")))
                    return
                end

                done((table.concat(out):gsub("%s+$", "")))
            end

            task = hs.task.new(rbw, function(code, stdout, stderr)
                collect(stdout, stderr)
                exitCode = code
                -- the stream callback gets one last call after this one, so
                -- let it land before consuming the output
                hs.timer.doAfter(0, deliver)
            end, function(t, stdout, stderr)
                collect(stdout, stderr)

                if t == nil then
                    deliver()
                end

                return true
            end, args)

            if not task then
                hs.alert.show("rbw: could not spawn " .. rbw)
                return
            end

            running[task] = true
            task:start()
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

        -- Frecency, zoxide style: a decaying use count kept in hs.settings
        -- (NSUserDefaults), so it survives reloads and restarts.
        local USES_KEY = "rbw.uses"

        local function uses()
            return hs.settings.get(USES_KEY) or {}
        end

        local function remember(id)
            local stats = uses()
            local entry = stats[id] or { count = 0 }

            entry.count = entry.count + 1
            entry.last = os.time()
            stats[id] = entry

            hs.settings.set(USES_KEY, stats)
        end

        -- Capped so frecency only ever breaks ties between comparable matches:
        -- an entry you use daily should win over one you never touch, but it
        -- should not outrank a plainly better match on the name.
        local function boost(entry)
            if not entry or not entry.last then
                return 0
            end

            local age = os.time() - entry.last
            local factor

            if age < 3600 then
                factor = 4
            elseif age < 86400 then
                factor = 2
            elseif age < 604800 then
                factor = 0.5
            else
                factor = 0.25
            end

            return math.min(entry.count * factor * 3, 30)
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

                    local stats = uses()
                    local choices = {}

                    for _, entry in ipairs(entries) do
                        if entry["type"] == "Login" then
                            table.insert(choices, {
                                ["text"] = entry.name,
                                ["subText"] = subText(entry),
                                ["uuid"] = entry.id,
                                ["boost"] = boost(stats[entry.id]),
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
                            remember(choice.uuid)
                            action(choice.uuid)
                        end,
                    })
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

    ".hammerspoon/spotify.lua".text =
      lib.optionalString config.programs.spotify-player.enable
      /*
      lua
      */
      ''
        local function spotify_player_command(command)
            os.execute("${lib.getExe config.programs.spotify-player.package} playback " .. command)
        end

        local M = {
            playlists_path = "/tmp/playlists.json",
        }

        function M.fetch_playlists()
            local c = [[${lib.getExe config.programs.spotify-player.package} get key user-playlists > ]] .. M.playlists_path
            os.execute(c)
        end

        function M.play_playlist(is_retry)
            local f = io.open(M.playlists_path, "r")
            if not f then
                if is_retry then
                    hs.alert.show("Failed to read playlists")
                    return
                end

                local r = false
                if not is_retry then
                    r = true
                end

                M.play_playlist(r)
            end

            local playlists_json = f:read("*all")
            f:close()

            local playlists_cache = hs.json.decode(playlists_json)

            local choices = {}

            for _, playlist in pairs(playlists_cache) do
                local choice = {
                    ["text"] = playlist.name,
                    ["subText"] = "",
                    ["uuid"] = playlist.id,
                }

                table.insert(choices, choice)
            end

            local chooser = hs.chooser.new(function(selected)
                if not selected then
                    return
                end
                local c = "${lib.getExe config.programs.spotify-player.package} playback start context --id "
                    .. selected.uuid
                    .. " playlist"
                os.execute(c)
            end)

            chooser:choices(choices)
            chooser:show()
        end

        -- run `ncspot info` and get result
        function M.play_pause()
            spotify_player_command("play-pause")
        end

        function M.prev()
            spotify_player_command("previous")
        end

        function M.next()
            spotify_player_command("next")
        end

        function M.ff()
            spotify_player_command("seek 5000")
        end

        function M.rw()
            spotify_player_command("seek -- -5000")
        end

        return M
      '';
  };
}
