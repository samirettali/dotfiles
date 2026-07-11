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

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    samirettali-nur = {
      url = "github:samirettali/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gwfox = {
      url = "github:akkva/gwfox?ref=main";
      flake = false;
    };

    spoons = {
      url = "github:Hammerspoon/Spoons";
      flake = false;
    };

    control-escape-spoon = {
      url = "github:jasonrudolph/ControlEscape.spoon";
      flake = false;
    };

    hallmark = {
      url = "github:nutlope/hallmark";
      flake = false;
    };

    agent-stuff = {
      url = "github:mitsuhiko/agent-stuff";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    darwin,
    home-manager,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    # Constants
    stateVersion = "26.11";
    defaultUser = "samir";

    # System configurations
    systems = {
      darwin = "aarch64-darwin";
      linux = "x86_64-linux";
      server = "aarch64-linux";
    };

    # User configurations
    users = {
      personal = {
        name = defaultUser;
        homeDirectory = "/Users/${defaultUser}";
        email = "samir@ettali.com";
      };
    };

    # Default feature toggles; override per machine at the call site.
    defaultFeatures = {
      rust = true;
      dart = false;
      security = false;
      web3 = false;
      zig = false;
      java = false;
      js = "minimal";
      c = false;
      go = true;
      python = "minimal";
    };

    mkNeovimPackage = system:
      inputs.neovim-nightly-overlay.packages.${system}.default.overrideAttrs (_: {
        doCheck = false; # TODO: upstream is broken
      });

    # Common Nix configuration
    mkNixConfig = {username ? defaultUser, ...}: {
      enable = true;
      settings = {
        allowed-users = [username];
        trusted-users = ["root" username];
        experimental-features = ["nix-command" "flakes"];
        extra-substituters = [
          "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
      optimise.automatic = false;
    };

    nixpkgsConfig = {
      config = {
        allowUnfree = true;
      };
    };

    # Common Home Manager configuration
    mkHomeManagerConfig = {
      user,
      extraModules ? [],
      features ? defaultFeatures,
      pkgs,
      ...
    }: {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = {
        inherit inputs;
        nurPkgs = inputs.samirettali-nur.packages.${pkgs.stdenv.hostPlatform.system};
        neovimPackage = mkNeovimPackage pkgs.stdenv.hostPlatform.system;
        vscodeExtLib = inputs.nix4vscode.lib.${pkgs.stdenv.hostPlatform.system};
        vars = {
          inherit (user) email;
          font = {
            name = "JetBrainsMono Nerd Font";
            size =
              if pkgs.stdenv.isDarwin
              then 16
              else 10;
          };
          commands = {
            # TODO: find a better way
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
      users.${user.name} = {
        inherit features;

        imports =
          [
            ./home
          ]
          ++ extraModules;

        home = {
          inherit stateVersion;
          inherit (user) homeDirectory;
          username = user.name;
        };
      };
    };
  in {
    homeConfigurations = {
      andromeda = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = systems.server;
          inherit (nixpkgsConfig) config;
        };

        extraSpecialArgs = {
          inherit inputs;
          nurPkgs = inputs.samirettali-nur.packages.${systems.server};
          neovimPackage = mkNeovimPackage systems.server;
          vars.email = users.personal.email;
        };

        modules = [
          ./home/ai.nix
          ./home/server.nix
          ({pkgs, ...}: {
            features.python = "minimal";

            home = {
              username = defaultUser;
              homeDirectory = "/home/${defaultUser}";
              inherit stateVersion;
            };

            programs.home-manager.enable = true;

            home.packages = with pkgs; [
              ghostty.terminfo
            ];

            home.file.".terminfo".source = "${pkgs.ghostty.terminfo}/share/terminfo";
          })
        ];
      };
    };

    darwinConfigurations = {
      mbp = darwin.lib.darwinSystem {
        system = systems.darwin;
        specialArgs = {inherit inputs;};
        modules = [
          ./machines/mbp.nix
          ({
            config,
            pkgs,
            ...
          }: {
            nix = mkNixConfig {
              username = users.personal.name;
            };

            nixpkgs = nixpkgsConfig;

            system.stateVersion = 6;
            system.primaryUser = users.personal.name;

            users.users.${users.personal.name} = {
              home = users.personal.homeDirectory;
              shell = pkgs.fish;
            };
            environment.shellAliases = config.home-manager.users."${defaultUser}".home.shellAliases;
          })
          home-manager.darwinModules.home-manager
          ({pkgs, ...}: {
            home-manager = mkHomeManagerConfig {
              inherit pkgs;
              user = users.personal;
              features = defaultFeatures;
              extraModules = [
                ./home/mac
                ./home/packages/desktop
                ./home/packages/dev
                ./home/packages/security.nix
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
              features = defaultFeatures;
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
