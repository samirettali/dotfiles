{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    nil
    nixd
  ];

  programs.vscode.profiles.default = {
    extensions = pkgs.nix4vscode.forVscodeVersionPrerelease config.programs.vscode.package.version [
      "jnoortheen.nix-ide"
    ];
    userSettings = {
      "nix.formatterPath" = "alejandra";
    };
  };
}
