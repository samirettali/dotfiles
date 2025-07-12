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
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    samirettali-nur = {
      url = "github:samirettali/nur";
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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-rs = {
      url = "github:richardscollin/tmux-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    television = {
      # https://github.com/alexpasmantier/television
      url = "github:alexpasmantier/television";
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
    inherit (nixpkgs) lib;

    # Constants
    stateVersion = "25.11";
    defaultUser = "samir";

    # System configurations
    systems = {
      darwin = "aarch64-darwin";
      linux = "x86_64-linux";
    };

    # User configurations
    users = {
      personal = {
        name = defaultUser;
        homeDirectory = "/home/${defaultUser}";
        email = "ettali.samir@gmail.com";
      };
      work = {
        name = "s.ettali";
        homeDirectory = "/Users/s.ettali";
        email = "s.ettali@young.business";
      };
    };

    # Common Nix configuration
    mkNixConfig = {username ? defaultUser, ...}: {
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
        nix-vscode-extensions.overlays.default
        rust-overlay.overlays.default
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

    # Common Home Manager configuration
    mkHomeManagerConfig = {
      user,
      extraModules ? [],
      pkgs,
      ...
    }: {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = {
        inherit inputs;
        inherit (inputs) samirettali-nur tmux-rs;
        inherit (mkCustomArgs pkgs) customArgs;
      };
      users.${user.name} = {
        imports =
          [
            ./home
          ]
          ++ extraModules;

        home = {
          inherit stateVersion;
          homeDirectory = user.homeDirectory;
          username = user.name;
          sessionVariables.EMAIL = user.email;
        };
      };
    };
  in {
    darwinConfigurations = {
      settali = darwin.lib.darwinSystem {
        system = systems.darwin;
        specialArgs = {inherit inputs;};
        modules = [
          ./machines/mbp.nix
          ./darwin/homebrew.nix
          ./darwin/work.nix
          ({pkgs, ...}: {
            nix = mkNixConfig {
              username = users.work.name;
            };

            nixpkgs = nixpkgsConfig;

            system.stateVersion = 6;
            system.primaryUser = users.work.name;

            users.users.${users.work.name} = {
              home = users.work.homeDirectory;
              shell = pkgs.fish;
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJdetGPFJw+CH6wNU4BinYePWVypM42s9WI0XPodihl samir"
              ];
            };
          })
          home-manager.darwinModules.home-manager
          ({pkgs, ...}: {
            home-manager = mkHomeManagerConfig {
              inherit pkgs;
              user = users.work;
              extraModules = [
                ./home/mac.nix
                ./home/packages/desktop
                ./home/packages/dev
                ./home/packages/work.nix
                ./home/packages/security.nix
                ./darwin/aerospace.nix
              ];
            };
          })
        ];
      };
    };

    nixosConfigurations = {
      xps = lib.nixosSystem {
        system = systems.linux;
        specialArgs = {
          inherit inputs;
          user = users.personal.name;
        };
        modules = [
          ./machines/xps/configuration.nix
          ./machines/xps/hardware-configuration.nix
          ({pkgs, ...}: {
            nix =
              mkNixConfig {}
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

            users.users.${users.personal.name} = {
              home = users.personal.homeDirectory;
              shell = pkgs.fish;
              isNormalUser = true;
            };
          })
          home-manager.nixosModules.home-manager
          ({pkgs, ...}: {
            home-manager = mkHomeManagerConfig {
              inherit pkgs;
              user = users.personal;
              extraModules = [
                ./home/linux
                ./home/linux/desktop
                ./home/packages/desktop
                ./home/packages/dev
                ./home/packages/security.nix
              ];
            };
          })
        ];
      };
    };
  };
}
