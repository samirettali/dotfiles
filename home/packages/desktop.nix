{ pkgs, ... }: {
  home.packages = with pkgs; [
    keepassxc
    qbittorrent
    spotify
  ];

  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        golang.go
      ];
    };
  };
}
