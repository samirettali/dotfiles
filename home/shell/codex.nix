{pkgs, ...}: let
  codexRepo = pkgs.fetchFromGitHub {
    owner = "ymichael";
    repo = "open-codex";
    rev = "c15beb3a3f9ef393e597a1ea6d5c0c84022b36d3";
    hash = "sha256-GqyrMo6yCP6zP5bN45UJM8b9341IRIOsLIG42flbDLc=";
  };
in
  pkgs.buildNpmPackage rec {
    pname = "codex-cli";
    version = "unstable";
    src = "${codexRepo}/codex-cli";
    buildInputs = [
      pkgs.nodejs
      pkgs.nodePackages.npm
    ];
    npmDepsHash = "sha256-W7vOIUGWhoJhiJGSMSNLJhChCjBcG5qBlwuMBSXWGgQ=";
  }
