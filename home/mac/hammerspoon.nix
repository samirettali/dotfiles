{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nur.repos.natsukium.hammerspoon
  ];

  home.file = {
    ".hammerspoon/Spoons/RecursiveBinder.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "samirettali";
        repo = "RecursiveBinder.spoon";
        rev = "main";
        sha256 = "sha256-KcxZzYpfuCZy6p+ixvGJszKrRplPsXrr1ICfCw2k1xM=";
      };
    };
    ".hammerspoon/Spoons/ControlEscape.spoon" = {
      source = pkgs.fetchFromGitHub {
        owner = "jasonrudolph";
        repo = "ControlEscape.spoon";
        rev = "main";
        sha256 = "sha256-aTCjdTdDOQMFcML4/C2M7dBPwkI4paOjQR7euNDRuao=";
      };
    };
  };

  # TODO
  # osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:true}' > /dev/null

  home.file = {
    ".hammerspoon" = {
      source = ../dotfiles/hammerspoon;
      recursive = true;
    };
    ".hammerspoon/spotify.lua".text =
      lib.optionals (config.programs.spotify-player.enable)
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
