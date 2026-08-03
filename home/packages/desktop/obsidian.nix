{pkgs, ...}: {
  programs.obsidian = {
    enable = true;
    cli.enable = true;

    # TODO: upstream broken
    package = pkgs.obsidian.overrideAttrs (old:
      pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        sourceRoot = "Obsidian ${old.version}-universal/Obsidian.app";
      });
  };
}
