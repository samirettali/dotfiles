{pkgs, ...}: {
  home.packages = with pkgs; [
    # burpsuite
    amass
    cent
    dnsx
    ffuf
    findomain
    httpx
    naabu
    nmap
    nuclei
    nuclei-templates
    sqlmap
    subfinder
  ];
}
