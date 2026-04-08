{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    nixd
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
