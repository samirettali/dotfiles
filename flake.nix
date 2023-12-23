{
  description = "Home Manager configuration of samir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    fenix-overlay.url = "github:nix-community/fenix";
    nur.url = "github:nix-community/NUR";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
    let
      stateVersion = "23.11";
      user = "samir";
      homeDirectory = "/home/${user}";

      nixConfig = { username ? user, ... }: {
        allowed-users = [ username ];
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        # gc = {
        #   automatic = true;
        #   dates = "weekly";
        #   options = "--delete-older-than 7d";
        # };
      };

      overlays = with inputs; [
        neovim-nightly-overlay.overlay
        fenix-overlay.overlays.default
        nur.overlay
      ];

    in
    {
      darwinConfigurations.work = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/mbp.nix
          ./darwin/homebrew.nix
          ({ lib, pkgs, system, ... }: {
            nixpkgs.config.allowUnfree = lib.mkDefault true;
            nixpkgs.overlays = overlays;

            system.stateVersion = 4;

            users.users."s.ettali" = {
              home = "/Users/s.ettali";
              shell = pkgs.zsh;
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJdetGPFJw+CH6wNU4BinYePWVypM42s9WI0XPodihl samir"
              ];
            };

            nix = {
              package = pkgs.nixFlakes;
              settings = nixConfig { username = "s.ettali"; };
            };
          })
          home-manager.darwinModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # makes all inputs available in imported files for hm
              extraSpecialArgs = { inherit inputs; };
              users."s.ettali" = { system, ... }: with inputs; {
                imports = [
                  ./home
                  ./home/mac.nix
                  ./home/packages/work.nix
                  ./home/packages/desktop.nix
                  ./home/packages/dev.nix
                ];
                home.stateVersion = stateVersion;
                home.homeDirectory = "/Users/s.ettali";
                home.username = "s.ettali";
              };
            };
          }
        ];
      };

      nixosConfigurations = {
        xps = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; inherit user; };
          modules = [
            ./machines/xps/configuration.nix
            ({ lib, pkgs, system, ... }: {
              nixpkgs.config.allowUnfree = lib.mkDefault true;
              nixpkgs.overlays = overlays;

              system.stateVersion = "unstable";
              users.users.${user} = {
                home = homeDirectory;
                shell = pkgs.zsh;
                isNormalUser = true;
              };
              nix = {
                package = pkgs.nixFlakes;
                settings = nixConfig { };
              };
            })
            home-manager.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.${user} = { system, ... }: {
                  imports = [
                    ./home
                    ./home/linux
                    ./home/linux/desktop
                    ./home/packages/desktop.nix
                    ./home/packages/dev.nix
                    ./home/packages/security.nix
                  ];
                  home.stateVersion = stateVersion;
                  home.homeDirectory = homeDirectory;
                  home.username = user;
                };
              };
            }
          ];
        };
      };
    };
}
