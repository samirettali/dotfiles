{
  description = "Home Manager configuration of samir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    foundry = {
      url = "github:shazow/foundry.nix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    darwin,
    home-manager,
    ...
  } @ inputs: let
    stateVersion = "25.05";
    user = "samir";
    homeDirectory = "/home/${user}";

    nixConfig = {username ? user, ...}: {
      allowed-users = [username];
      trusted-users = ["root" username];
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = false; # this breaks on macos
    };

    overlays = with inputs; [
      neovim-nightly-overlay.overlays.default
      nur.overlays.default
      foundry.overlay
    ];

    mkCustomArgs = pkgs: {
      customArgs = {
        font = {
          name = "JetBrainsMono Nerd Font";
          size =
            if pkgs.stdenv.isDarwin
            then 14
            else 10;
        };
      };
    };
  in {
    darwinConfigurations = {
      work = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules = [
          ./machines/mbp.nix
          ./darwin/homebrew.nix
          ./darwin/work.nix
          ({
            lib,
            pkgs,
            ...
          }: {
            nixpkgs.config.allowUnfree = lib.mkDefault true;
            nixpkgs.overlays = overlays;
            nixpkgs.config.permittedInsecurePackages = [
              "dotnet-combined"
              "dotnet-core-combined"
              "dotnet-wrapped-combined"
              "dotnet-sdk-6.0.428"
              "dotnet-sdk-wrapped-6.0.428"
            ];

            system.stateVersion = 5;
            ids.uids.nixbld = 350; # TODO: fix until update to sequoia

            users.users."s.ettali" = {
              home = "/Users/s.ettali";
              shell = pkgs.fish;
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJdetGPFJw+CH6wNU4BinYePWVypM42s9WI0XPodihl samir"
              ];
            };

            nix = {
              package = pkgs.nixVersions.stable;
              settings = nixConfig {username = "s.ettali";};
            };
          })
          home-manager.darwinModule
          ({pkgs, ...}: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # makes all inputs available in imported files for hm
              extraSpecialArgs = {
                inherit inputs;
                inherit (mkCustomArgs pkgs) customArgs;
              };
              users."s.ettali" = {...}: {
                imports = [
                  ./home
                  ./home/mac.nix
                  ./home/packages/desktop
                  ./home/packages/work.nix
                  ./home/packages/dev.nix
                ];
                home.stateVersion = stateVersion;
                home.homeDirectory = "/Users/s.ettali";
                home.username = "s.ettali";
                home.sessionVariables = {
                  EMAIL = "s.ettali@young.business";
                };
              };
            };
          })
        ];
      };
    };

    nixosConfigurations = {
      xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit user;
        };
        modules = [
          ./machines/xps/configuration.nix
          ./machines/xps/hardware-configuration.nix
          ({
            lib,
            pkgs,
            ...
          }: {
            nixpkgs.config.allowUnfree = lib.mkDefault true;
            nixpkgs.overlays = overlays;

            system.stateVersion = "unstable";
            users.users.${user} = {
              home = homeDirectory;
              shell = pkgs.zsh;
              isNormalUser = true;
            };
            nix = {
              package = pkgs.nixVersions.stable;
              settings = nixConfig {};
              optimise.automatic = true;
              gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 7d";
              };
            };
          })
          home-manager.nixosModule
          ({pkgs, ...}: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                inherit (mkCustomArgs pkgs) customArgs;
              };
              users.${user} = {...}: {
                imports = [
                  ./home
                  ./home/linux
                  ./home/linux/desktop
                  ./home/packages/desktop
                  ./home/packages/dev.nix
                  ./home/packages/security.nix
                ];
                home.stateVersion = stateVersion;
                home.homeDirectory = homeDirectory;
                home.username = user;
                home.sessionVariables = {
                  EMAIL = "ettali.samir@gmail.com";
                };
              };
            };
          })
        ];
      };
    };
  };
}
