{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    config.image-display-duration = 3;
    bindings = {
      "ctrl+r" = ''cycle_values video-rotate "90" "180" "270" "0"'';
    };
    scripts = with pkgs.mpvScripts; [
      autocrop
    ];
  };
}
