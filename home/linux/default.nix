{pkgs, ...}: {
  imports = [
    ./gpg.nix
  ];

  home.packages = with pkgs; [
    bcc
    poop
  ];
}
