{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.optionals config.features.security [
      # burpsuite
      amass
      android-tools
      apksigner
      apktool
      cent
      dex2jar
      dnsx
      ffuf
      findomain
      frida-tools
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
