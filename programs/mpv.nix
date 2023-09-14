{ ... }: {
  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.autocrop ];
  };
}
