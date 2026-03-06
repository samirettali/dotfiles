{
  pkgs,
  features,
  ...
}: let
in {
  home.packages = with pkgs;
    lib.optionals features.security [
      # burpsuite
      amass
      cent
      dnsx
      ffuf
      findomain
      ghidra-bin
      hakrawler
      httpx
      imhex
      # jadx # TODO: upstream is broken
      naabu
      nmap
      nuclei
      nuclei-templates
      sqlmap
      subfinder
    ];
}
