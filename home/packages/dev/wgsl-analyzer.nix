{
  lib,
  pkgs,
}:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wgsl-analyzer";
  version = "2025-06-02";

  src = pkgs.fetchFromGitHub {
    owner = "wgsl-analyzer";
    repo = "wgsl-analyzer";
    tag = finalAttrs.version;
    hash = "sha256-bLwehCmWzqDmmg4iGM21BOUquSYJSY2LIqlKuB1bAlA=";
  };

  cargoHash = "sha256-Z+slANnmrY5bhM8+Ki+l29OAbpqnx38n53CFCuOR6cM=";

  meta = {
    description = "a language server implementation for the WGSL shading language";
    homepage = "https://github.com/wgsl-analyzer/wgsl-analyzer";
    license = lib.licenses.unlicense;
    maintainers = [];
  };
})
