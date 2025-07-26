{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    # burpsuite
    amass
    cent
    dnsx
    ffuf
    # findomain # TODO: upstream is broken
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
