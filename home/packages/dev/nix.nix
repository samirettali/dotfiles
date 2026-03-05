{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    nixd
  ];

  programs.vscode.profiles.default = {
    extensions = pkgs.nix4vscode.forVscodeVersion config.programs.vscode.package.version [
      "jnoortheen.nix-ide"
    ];
    userSettings = {
      "nix.formatterPath" = "alejandra";
    };
  };
}
