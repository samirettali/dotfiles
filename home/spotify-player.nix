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
    };
    settings = {
      theme = "default";
      client_id = "9f04615abcca4c0d968bd207d2a66215";
      app_refresh_duration_in_ms = 16;
      # play_icon = "";
      # pause_icon = "";
      # liked_icon = "";
      seek_duration_secs = 5;
      default_device = config.home.username;
      enable_cover_image_cache = true;
      enable_notify = true;
      notify_streaming_only = false;
      enable_streaming = "DaemonOnly";
      cover_img_length = 9;
      cover_img_width = 9;
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
        "${pkgs.spotify-player.override {
          withAudioBackend = "rodio";
          withMediaControl = false;
        }}/bin/spotify_player"
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
