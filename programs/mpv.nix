{ pkgs
, ...
}: {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      autocrop
      thumbnail
      webtorrent-mpv-hook
    ];
  };
}
