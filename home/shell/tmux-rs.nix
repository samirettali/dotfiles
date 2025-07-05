{
  lib,
  rust-bin,
  fetchFromGitHub,
  makeRustPlatform,
  ncurses,
  libevent,
}: let
  rust = rust-bin.stable.latest.default.override {
    targets = ["aarch64-apple-darwin"];
  };
  rustPlatform = makeRustPlatform {
    cargo = rust;
    rustc = rust;
  };
in
  rustPlatform.buildRustPackage rec {
    pname = "tmux-rs";
    version = "unstable-2025-07-05";

    # add ncurses to buildInputs
    buildInputs = [ncurses libevent];

    # skip test_b64_pton_valid and test_b64_pton_partial test
    checkFlags = ["--skip" "test_b64_pton_valid" "--skip" "test_b64_pton_partial"];

    src = fetchFromGitHub {
      owner = "richardscollin";
      repo = "tmux-rs";
      rev = "0799845c688bc3be0957796ad35f5a41bbbc9dce";
      hash = "sha256-s94zoE99dd8okZtpWt1a5iCggNh7MI8RxMAt+JD26bQ=";
    };

    cargoHash = "sha256-uDNBIOxp7/zmiNEXmuU6/9vnfkCsq28pZ5IBQ8+lXLc=";

    meta = {
      description = "A Rust port of tmux";
      homepage = "https://github.com/richardscollin/tmux-rs";
      license = lib.licenses.unfree; # FIXME: nix-init did not find a license
      maintainers = with lib.maintainers; [];
      mainProgram = "tmux-rs";
    };
  }
