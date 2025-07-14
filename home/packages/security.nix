{pkgs, ...}: let
  findomainPkgs =
    import (builtins.fetchGit {
      name = "findomain903";
      url = "https://github.com/NixOS/nixpkgs/";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "0bd7f95e4588643f2c2d403b38d8a2fe44b0fc73";
    }) {
      system = pkgs.system;
    };

  findomain903 = findomainPkgs.findomain;
in {
  home.packages = with pkgs; [
    # burpsuite
    amass
    cent
    dnsx
    ffuf
    findomain903 # TODO: upstream is broken
    ghidra-bin
    hakrawler
    httpx
    imhex
    jadx
    naabu
    nmap
    nuclei
    nuclei-templates
    sqlmap
    subfinder
  ];
}
