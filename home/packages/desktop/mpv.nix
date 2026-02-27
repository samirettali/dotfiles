{pkgs, ...}: {
  programs.mpv = {
    enable = false; # TODO: upstream is broken
    config.image-display-duration = 3;
    bindings = {
      "ctrl+r" = ''cycle_values video-rotate "90" "180" "270" "0"'';
    };
    scripts = with pkgs.mpvScripts; [
      autocrop
    ];
  };
}
