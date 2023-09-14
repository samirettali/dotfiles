{
  description = "Home Manager configuration of samir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    fenix-overlay.url = "github:nix-community/fenix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , flake-utils
    , nixpkgs
    , home-manager
    , ...
    }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # devShell = pkgs.mkShell {
      #   buildInputs = with pkgs; [alejandra];
      # };
      defaultApp = {
        type = "app";
        program = "${home-manager.packages.${system}.default}/bin/home-manager";
      };
    }))
    // (
      let
        homeManagerModules =
          { system
          , username
          , homeDirectory
          , profile
          , stateVersion
          ,
          }:
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [ inputs.neovim-nightly-overlay.overlay inputs.fenix-overlay.overlays.default ];
            };
          in
          [
            (import ./home.nix {
              inherit username homeDirectory stateVersion pkgs nixpkgs profile home-manager;
            })
          ];

        rawHomeManagerConfigurations = {
          "Linux" = {
            system = "x86_64-linux";
            username = "samir";
            host = "xps";
            homeDirectory = "/home/samir";
            profile = "personal";
            stateVersion = "23.11";
          };
          "Darwin" = {
            system = "aarch64-darwin";
            username = "s.ettali";
            host = "s.ettali.local";
            homeDirectory = "/Users/s.ettali";
            profile = "work";
            stateVersion = "23.11";
          };
        };

        homeManagerConfiguration =
          { system
          , username
          , host
          , homeDirectory
          , profile
          , stateVersion
          ,
          }: (
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = homeManagerModules { inherit system username homeDirectory profile stateVersion; };
            }
          );
      in
      {
        # Export home-manager configurations
        inherit rawHomeManagerConfigurations;
        homeConfigurations =
          nixpkgs.lib.attrsets.mapAttrs
            (userAndHost: userAndHostConfig: homeManagerConfiguration userAndHostConfig)
            rawHomeManagerConfigurations;

      }
    )
    // {
      # Re-export devenv, flake-utils, home-manager and nixpkgs as usable outputs
      inherit flake-utils home-manager nixpkgs;
    };

}
