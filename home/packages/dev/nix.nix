{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    nil
    nixd
  ];

  programs.vscode.profiles.default = {
    extensions = with pkgs.vscode-marketplace; [
      jnoortheen.nix-ide
    ];
    userSettings = {
      "nix.formatterPath" = "alejandra";
    };
  };
}
