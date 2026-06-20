{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    nixd
    statix
  ];

  dotfiles.vscode.extensionIds = [
    "jnoortheen.nix-ide"
  ];

  programs.vscode.profiles.default = {
    userSettings = {
      "nix.formatterPath" = "alejandra";
    };
  };
}
