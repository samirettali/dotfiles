{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    amass
    burpsuite
    dnsx
    ffuf
    findomain
    httpx
    naabu
    sqlmap
    nmap
  ];
}
