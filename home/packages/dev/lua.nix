{
  lib,
  pkgs,
  config,
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

  programs.vscode.profiles.default = {
    extensions = pkgs.nix4vscode.forVscodeVersionPrerelease config.programs.vscode.package.version [
      "sumneko.lua"
      "johnnymorganz.stylua"
    ];
    userSettings = {
      "Lua.format.enable" = false;
      "stylua.styluaPath" = lib.getExe pkgs.stylua; # TODO: it doesn't use the same format as neovim
    };
  };
}
