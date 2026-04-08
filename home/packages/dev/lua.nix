{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (luajit.withPackages
      (ps:
        with ps; [
          cjson
          fzy
          luasocket
        ]))
    lua-language-server
    stylua
  ];

  dotfiles.vscode.extensionIds = [
    "sumneko.lua"
    "johnnymorganz.stylua"
  ];

  programs.vscode.profiles.default = {
    userSettings = {
      "Lua.format.enable" = false;
      "stylua.styluaPath" = lib.getExe pkgs.stylua; # TODO: it doesn't use the same format as neovim
    };
  };
}
