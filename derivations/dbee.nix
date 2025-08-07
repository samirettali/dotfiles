{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
  source,
}:
buildGoModule rec {
  pname = "nvim-dbee";
  version = "0.1.9";

  src = source;

  vendorHash = "sha256-zBWQu37kAaOKLZMkUtsVfRcQD5w7XUI6weZtl/OrVBI=";

  doCheck = false;

  buildInputs = with pkgs; [
    arrow-cpp
    duckdb
  ];

  meta = {
    description = "Interactive database client for neovim";
    homepage = "https://github.com/kndndrj/nvim-dbee/dbee";
    license = lib.licenses.gpl3Only;
    maintainers = [];
    mainProgram = "nvim-dbee";
    platforms = lib.platforms.all;
  };
}
