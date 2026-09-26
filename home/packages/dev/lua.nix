{pkgs, ...}: {
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

  dotfiles.neovim.lspServers = ["lua_ls" "stylua"];
}
