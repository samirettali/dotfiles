{
  pkgs,
  customArgs,
  ...
}: let
  scripts = with pkgs; [
    (callPackage
      ./nh.nix
      {
        copyCmd = customArgs.commands.copy;
      })
  ];
in {
  home.packages = scripts;
}
