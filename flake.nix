{
  description = "Home Manager configuration of samir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    fenix-overlay.url = "github:nix-community/fenix";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

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

      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        xps = lib.nixosSystem {
          inherit system;

          modules = [
            ./system/configuration.nix
          ];
        };
      };

      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

      homeConfigurations."samir" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./home.nix ];
      };
    };
}
