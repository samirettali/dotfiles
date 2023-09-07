{
  description = "Home Manager configuration of samir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwl-source = {
      url = "github:djpohly/dwl/c1d8b77f7fb4f082b7eb43474a788e9b5fe04e29";
      flake = false;
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    fenix-overlay.url = "github:nix-community/fenix";
  };

  outputs = { nixpkgs, home-manager, dwl-source, ... }@inputs:
    let
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
      overlays = [
        inputs.neovim-nightly-overlay.overlay
        inputs.fenix-overlay
      ];
      neovim = inputs.neovim-nightly-overlay.overlay;
      fenix = inputs.fenix-overlay.overlays.default;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ neovim fenix ];
      };
    in {
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      homeConfigurations."samir" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
            inherit dwl-source;
        };
      };
    };
}
