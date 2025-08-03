{
  config,
  lib,
  pkgs,
  ...
}: let
in {
  programs.spotify-player = {
    enable = true;
    package = pkgs.spotify-player.override {
      withMediaControl = false;
      withImage = false; # TODO: this is broken inside zellij/ghostty
      withSixel = false;
    };
    settings = {
      theme = "default";
      client_id = "9f04615abcca4c0d968bd207d2a66215";
      app_refresh_duration_in_ms = 16;
      playback_refresh_duration_in_ms = 1000;
      seek_duration_secs = 5;
      default_device = config.home.username;
      enable_cover_image_cache = true;
      enable_notify = true;
      client_port = 9999;
      notify_streaming_only = false;
      enable_streaming = "DaemonOnly";
      cover_img_width = 6;
      cover_img_length = 13;
      device = {
        name = config.home.username;
        device_type = "speaker";
        volume = 100;
        bitrate = 320;
        audio_cache = true;
        normalization = false;
        autoplay = false;
      };
      player_event_hook_command.command = lib.optionals config.programs.sketchybar.enable (
        let
          hook = import ./sketchybar-hook.nix {
            inherit pkgs config lib;
          };
        in
          lib.getExe hook
      );
    };
  };

  launchd.agents.spotify-player = lib.mkIf (config.programs.spotify-player.enable
    && pkgs.stdenv.isDarwin) {
    enable = true;
    config = {
      ProgramArguments = [
        (lib.getExe
          config.programs.spotify-player.package)
        "-d"
      ];
      RunAtLoad = true;
      KeepAlive = {
        Crashed = true;
        SuccessfulExit = false;
      };
      StandardOutPath = "/tmp/spotify-player.log";
      StandardErrorPath = "/tmp/spotify-player.error.log";
      ProcessType = "Background";
    };
  };
}
