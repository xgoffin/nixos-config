{
  description = "Work system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    man-tools = {
      url = "path:/home/xgoffin/Code/man";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };
    uds = {
      url = "path:/home/xgoffin/Code/uds";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };
    helm-charts = {
      url = "path:/home/xgoffin/Code/helm-charts";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };
    tcurl = {
      url = "path:/home/xgoffin/Code/tcurl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thrift-ls = {
      url = "github:karitham/thrift-ls";
    };
    tbuild = {
      url = "path:/home/xgoffin/Code/tbuild";
      inputs.nixpkgs.follows = "nixpkgs";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
    nixosConfigurations.nixos= nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        ./ninjaone.nix

        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            extraSpecialArgs = { inherit inputs; };
            users.xgoffin = ./home.nix;
          };
        }

        {
          services.logind.settings.Login = {
            HandleLidSwitch = "ignore";
            HandleLidSwitchExternalPower = "ignore";
            HandleLidSwitchDocked = "ignore";
          };
        }
        ({pkgs, ...}: {
          services.dbus.packages = [pkgs.gcr];
          programs.gnupg.agent = {
            enable = true;
          };
        })

        nixos-hardware.nixosModules.dell-xps-13-9315

        {
          services.ninjaone = {
            enable = true;
            installerPath = "/opt/NinjaOne-Agent-UpfluenceLyon-Bureauprincipal-Auto-x86-64.deb";
          };
        }
      ];
    };

    devShells.${system}.default = import ./shell.nix {
      inherit pkgs inputs;
      lib = nixpkgs.lib;
    };
  };
}
