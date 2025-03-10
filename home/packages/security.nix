{pkgs, ...}: {
  home.packages = with pkgs; [
    # burpsuite
    amass
    cent
    dnsx
    hakrawler
    ffuf
    findomain
    httpx
    jadx
    naabu
    ghidra-bin
    nmap
    nuclei
    nuclei-templates
    sqlmap
    subfinder
    rlwrap # TODO: move to shell/default.nix
  ];
}
