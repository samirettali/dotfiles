{pkgs, ...}: {
  home.pacakges = with pkgs; [
    cargo
    clippy
    rustc
    rustfmt
    cargo-watch
    cargo-generate
    rust-analyzer
  ];
}
