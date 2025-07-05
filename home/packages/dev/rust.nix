{pkgs, ...}: {
  home.packages = with pkgs; [
    (rust-bin.stable.latest.default.override
      {
        extensions = [
          "clippy"
          "rust-src"
          "rust-analyzer"
        ];
        targets = ["x86_64-unknown-linux-gnu"];
      })
  ];
}
