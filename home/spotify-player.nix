{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.spotify-player = {
    # TODO: add sketchybar hooks
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
      notify_streaming_only = false;
      enable_streaming = "DaemonOnly";
      device = {
        name = config.home.username;
        device_type = "speaker";
        volume = 100;
        bitrate = 320;
        audio_cache = true;
        normalization = false;
        autoplay = false;
      };
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
