{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    clippy
    rustc
    rustfmt
    cargo-watch
    cargo-generate
    rust-analyzer
  ];
}
