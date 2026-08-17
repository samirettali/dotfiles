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
      text = text.replace(old, new)

      # The helper walks keyFuncNameTable with pairs(), so the rows come out in
      # hash order: not the order of the config, and not stable across reloads.
      # Sort by key so the position of an entry is something to remember.
      old = """   local count = 0
         for keyName, funcName in pairs(keyFuncNameTable) do
      """
      new = """   local count = 0
         local keyNames = {}
         for keyName in pairs(keyFuncNameTable) do
            table.insert(keyNames, keyName)
         end
         table.sort(keyNames)
         for _, keyName in ipairs(keyNames) do
            local funcName = keyFuncNameTable[keyName]
      """
      assert old in text, "RecursiveBinder helper loop moved"
      text = text.replace(old, new)

      text = text.replace("local obj={}", 'local modalFocus = require("modal_focus")\n\nlocal obj={}')

      # Secure Input prevents Hammerspoon from receiving the unmodified keys
      # used inside the modal. Let modal_focus move focus away from the caller,
      # then restore it before running a leaf action or cancelling.
      text = text.replace("key, i.e. 'f' \n", "key, i.e. 'f'\n")
      old = """function obj.recursiveBind(keymap, modals)
         if not modals then modals = {} end
         if type(keymap) == 'function' then
            -- in this case "keymap" is actuall a function
            return keymap
         end
         local modal = hs.hotkey.modal.new()
         table.insert(modals, modal)
         local keyFuncNameTable = {}
         for key, map in pairs(keymap) do
            local func = obj.recursiveBind(map, modals)
            -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f'
            modal:bind(key[1], key[2], function() modal:exit() killHelper() func() end)
            modal:bind(obj.escapeKey[1], obj.escapeKey[2], function() modal:exit() killHelper() end)
            if #key >= 3 then
               keyFuncNameTable[createKeyName(key)] = key[3]
            end
         end
         return function()
            -- exit all modals, accounts for pressing the trigger key while
            -- a modal is already open
            for _, modal in pairs(modals) do
               modal:exit()
            end
            modal:enter()
            killHelper()
            if obj.showBindHelper then
               showHelper(keyFuncNameTable)
            end
         end
      end
      """
      new = """function obj.recursiveBind(keymap, modals, state)
         if not modals then
            modals = {}
            state = {}
         end
         if type(keymap) == 'function' then
            -- in this case "keymap" is actuall a function
            return keymap
         end

         local function restoreFocus()
            local focus = state.focus
            state.focus = nil
            state.active = false
            modalFocus.restore(focus)
         end

         local modal = hs.hotkey.modal.new()
         table.insert(modals, modal)
         local keyFuncNameTable = {}
         for key, map in pairs(keymap) do
            local func = obj.recursiveBind(map, modals, state)
            -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f'
            modal:bind(key[1], key[2], function()
               modal:exit()
               killHelper()
               if type(map) == 'function' then restoreFocus() end
               func()
            end)
            modal:bind(obj.escapeKey[1], obj.escapeKey[2], function()
               modal:exit()
               killHelper()
               restoreFocus()
            end)
            if #key >= 3 then
               keyFuncNameTable[createKeyName(key)] = key[3]
            end
         end
         return function()
            -- exit all modals, accounts for pressing the trigger key while
            -- a modal is already open
            for _, modal in pairs(modals) do
               modal:exit()
            end
            if not state.active then
               state.focus = modalFocus.take()
               state.active = true
            end
            modal:enter()
            killHelper()
            if obj.showBindHelper then
               showHelper(keyFuncNameTable)
            end
         end
      end
      """
      assert old in text, "RecursiveBinder implementation moved"
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
        local remoteImage = require("remote_image")
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

        local function imageProvider(playlistImages)
            if not playlistImages or #playlistImages == 0 then
                return nil
            end

            -- Spotify orders playlist images largest first. The smallest one
            -- is still larger than the row and avoids downloading a 640px
            -- mosaic for a 38px slot.
            return remoteImage.provider(playlistImages[#playlistImages].url)
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
            run({ "playlist", "list", "--full" }, function(stdout)
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
                        ["subText"] = playlist.tracks.total .. " tracks",
                        ["uuid"] = playlist.id,
                        ["boost"] = score(playlist.id),
                        ["imageProvider"] = imageProvider(playlist.images),
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

    # linkding answers a search in ~490ms over the tailnet, which is the whole
    # problem behind an interactive picker, so this keeps spotctl's shape: read
    # the local cache, refresh behind it. The cache is a JSON file rather than
    # sqlite because the data layer here is one GET with a static token — a CLI
    # like spotctl earns its keep on OAuth and playback, not on this.
    ".hammerspoon/bookmarks.lua".text =
      /*
      lua
      */
      ''
        local canvas = require("canvas")
        local frecency = require("frecency")
        local remoteImage = require("remote_image")
        local task = require("task")

        local BASE = "https://links.samirettali.com"
        local rbw = "${lib.getExe config.programs.rbw.package}"
        local CACHE_DIR = os.getenv("HOME") .. "/.cache/hammerspoon"
        local CACHE_PATH = CACHE_DIR .. "/bookmarks.json"

        -- Archived is not "done" here, it is the curated half: the read-later
        -- firehose stays on the active endpoint, and a bookmark worth keeping
        -- gets archived. That makes the split structural rather than a tag
        -- convention, and it is why this list is small enough to refetch whole.
        local COLLECTION = "/api/bookmarks/archived/"

        local PAGE = 1000

        local M = {}

        local uses = frecency.new("bookmarks.uses")

        local token = nil

        -- One call per Hammerspoon session: the token is cached here, so the
        -- vault is asked when the first refresh runs and never again.
        local function readToken(done)
            if token then
                return done(token)
            end

            task.run(rbw, { "get", "linkding-api-key" }, function(out)
                token = (out:gsub("%s+$", ""))
                done(token)
            end, function(message)
                hs.alert.show("bookmarks: no token from the vault (" .. message .. ")")
            end)
        end

        -- only what the picker draws or opens, so the cache stays small enough
        -- to decode without the delay being noticeable
        local function trim(bookmark)
            local title = bookmark.title

            if title == nil or title == "" then
                title = bookmark.website_title
            end

            if title == nil or title == "" then
                title = bookmark.url
            end

            return {
                -- linkding ids are integers, and frecency uses them as keys in
                -- hs.settings, which is NSUserDefaults and takes strings only
                id = tostring(bookmark.id),
                url = bookmark.url,
                title = title,
                tags = bookmark.tag_names or {},
                favicon_url = bookmark.favicon_url,
            }
        end

        local function get(path, done)
            readToken(function(auth)
                hs.http.asyncGet(BASE .. path, { Authorization = "Token " .. auth }, function(status, body)
                    if status ~= 200 then
                        hs.alert.show("bookmarks: linkding answered " .. tostring(status))
                        return
                    end

                    local decoded = hs.json.decode(body)

                    if not decoded or not decoded.results then
                        hs.alert.show("bookmarks: could not parse the response")
                        return
                    end

                    done(decoded)
                end)
            end)
        end

        local function collect(offset, acc, done)
            get(COLLECTION .. "?limit=" .. PAGE .. "&offset=" .. offset, function(page)
                for _, bookmark in ipairs(page.results) do
                    acc[#acc + 1] = trim(bookmark)
                end

                if page.next then
                    collect(offset + PAGE, acc, done)
                else
                    done(acc)
                end
            end)
        end

        -- Everything the picker needs, decoded once and kept for the life of the
        -- config. hs.json.decode walks the payload into Lua tables one element
        -- at a time through the ObjC bridge, which is what made the picker slow
        -- to appear back when this read the whole 10k collection. None of it
        -- depends on the keypress, so none of it belongs behind one.
        local state = nil

        local function load()
            local file = io.open(CACHE_PATH, "r")

            if not file then
                return nil
            end

            local body = file:read("*a")
            file:close()

            local cache = hs.json.decode(body)

            if not cache or not cache.items then
                return nil
            end

            return cache
        end

        -- takes the two fields rather than the state table, which also carries
        -- the built rows: those are derived from the items and would double the
        -- file, and the decode of that file is the cost being avoided here
        local function save(syncedAt, items)
            hs.fs.mkdir(os.getenv("HOME") .. "/.cache")
            hs.fs.mkdir(CACHE_DIR)

            local file = io.open(CACHE_PATH, "w")

            if not file then
                hs.alert.show("bookmarks: could not write the cache")
                return
            end

            file:write(hs.json.encode({ synced_at = syncedAt, items = items }))
            file:close()
        end

        local function subText(item)
            local parts = {}
            local host = item.url:match("^https?://([^/]+)")

            if host then
                parts[#parts + 1] = (host:gsub("^www%.", ""))
            end

            if #item.tags > 0 then
                parts[#parts + 1] = table.concat(item.tags, " ")
            end

            return table.concat(parts, " · ")
        end

        local function build(items)
            local choices = {}

            for _, item in ipairs(items) do
                choices[#choices + 1] = {
                    ["text"] = item.title,
                    ["subText"] = subText(item),
                    ["uuid"] = item.id,
                    ["url"] = item.url,
                    ["boost"] = 0,
                    ["imageProvider"] = remoteImage.provider(item.favicon_url),
                }
            end

            return choices
        end

        local function adopt(syncedAt, items)
            state = { synced_at = syncedAt, items = items, choices = build(items) }
        end

        local function prime()
            if state then
                return true
            end

            local cache = load()

            if not cache or #cache.items == 0 then
                return false
            end

            adopt(cache.synced_at, cache.items)

            return true
        end

        -- A whole refetch rather than a modified_since delta: the collection is
        -- a few hundred rows in one request, and archiving or unarchiving moves
        -- a bookmark between endpoints instead of editing it, so a delta on this
        -- one would never see either. Refetching cannot drift.
        local function refresh()
            local started = os.time()

            collect(0, {}, function(items)
                adopt(started, items)
                save(started, items)
            end)
        end

        local function show()
            -- the rows themselves are already built; only the ranking they get
            -- ordered by can have moved since the last time
            local score = uses.scores()

            for _, choice in ipairs(state.choices) do
                choice.boost = score(choice.uuid)
            end

            canvas.picker({
                prompt = "bookmarks",
                choices = state.choices,
                onSelect = function(choice)
                    uses.remember(choice.uuid)
                    hs.urlevent.openURL(choice.url)
                end,
            })
        end

        function M.open()
            if prime() then
                show()

                -- the read never checks freshness, by design, so refresh behind
                -- the picker: this run stays instant, the next one is current
                refresh()
            else
                hs.alert.show("bookmarks: first sync")

                collect(0, {}, function(items)
                    local started = os.time()
                    adopt(started, items)
                    save(started, items)
                    show()
                end)
            end

            return true
        end

        -- Off the critical path rather than at require time: the config keeps
        -- loading, and the decode lands long before the first keypress.
        hs.timer.doAfter(0, prime)

        return M
      '';
  };
}
