{
  lib,
  nurPkgs,
  inputs,
  pkgs,
  ...
}: {
  programs.codex = {
    enable = lib.mkDefault true;
    package = nurPkgs.codex;
    skills = import ../shell/coding-agent-skills.nix {inherit inputs pkgs;};
  };
}
