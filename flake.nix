{
  description = "Home Manager configuration of samir";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # TODO: should use nixos-unstable for NixOS?

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";

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
  };

  outputs = {
    nixpkgs,
    darwin,
    home-manager,
    nix-vscode-extensions,
    ...
  } @ inputs: let
    stateVersion = "25.11";
    user = "samir";
    homeDirectory = "/home/${user}";

    defaultNixConfig = {username ? user, ...}: {
      enable = true;
      settings = {
        allowed-users = [username];
        trusted-users = ["root" username];
        experimental-features = ["nix-command" "flakes"];
      };
      optimise.automatic = true;
    };

    nixpkgsConfig = {
      overlays = with inputs; [
        neovim-nightly-overlay.overlays.default
        nur.overlays.default
        foundry.overlay
        nix-vscode-extensions.overlays.default
      ];
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "dotnet-combined"
          "dotnet-core-combined"
          "dotnet-wrapped-combined"
          "dotnet-sdk-6.0.428"
          "dotnet-sdk-wrapped-6.0.428"
        ];
      };
    };

    mkCustomArgs = pkgs: {
      customArgs = {
        font = {
          name = "JetBrainsMono Nerd Font";
          size =
            if pkgs.stdenv.isDarwin
            then 14
            else 10;
        };
        commands = {
          copy =
            if pkgs.stdenv.isDarwin
            then "pbcopy"
            else "xclip -selection clipboard";
          paste =
            if pkgs.stdenv.isDarwin
            then "pbpaste"
            else "xclip -o -selection clipboard";
        };
      };
    };
  in {
    darwinConfigurations = {
      settali = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules = [
          ./machines/mbp.nix
          ./darwin/homebrew.nix
          ./darwin/work.nix
          ({pkgs, ...}: {
            nix = defaultNixConfig {
              username = "s.ettali";
            };

            nixpkgs = nixpkgsConfig;

            system.stateVersion = 6;
            system.primaryUser = "s.ettali";

            users.users."s.ettali" = {
              home = "/Users/s.ettali";
              shell = pkgs.fish;
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJdetGPFJw+CH6wNU4BinYePWVypM42s9WI0XPodihl samir"
              ];
            };
          })
          home-manager.darwinModules.home-manager
          ({pkgs, ...}: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                inherit (mkCustomArgs pkgs) customArgs;
              };
              users."s.ettali" = {...}: {
                imports = [
                  ./home
                  ./home/mac.nix
                  ./home/packages/desktop
                  ./home/packages/dev
                  ./home/packages/work.nix
                  ./home/packages/security.nix
                  ./darwin/aerospace.nix
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
          ({pkgs, ...}: {
            nix =
              defaultNixConfig {}
              // {
                package = pkgs.nixVersions.stable;
                gc = {
                  automatic = true;
                  dates = "weekly";
                  options = "--delete-older-than 7d";
                };
              };

            nixpkgs = nixpkgsConfig;

            system.stateVersion = stateVersion;

            users.users.${user} = {
              home = homeDirectory;
              shell = pkgs.fish;
              isNormalUser = true;
            };
          })
          home-manager.nixosModules.home-manager
          ({pkgs, ...}: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
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
                  ./home/packages/dev
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
