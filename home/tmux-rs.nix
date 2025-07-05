{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "tmux-rs";
  version = "unstable-2025-07-05";

  src = fetchFromGitHub {
    owner = "richardscollin";
    repo = "tmux-rs";
    rev = "0799845c688bc3be0957796ad35f5a41bbbc9dce";
    hash = "sha256-s94zoE99dd8okZtpWt1a5iCggNh7MI8RxMAt+JD26bQ=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = {
    description = "A Rust port of tmux";
    homepage = "https://github.com/richardscollin/tmux-rs";
    license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [];
    mainProgram = "tmux-rs";
  };
}
