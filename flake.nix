{
  description = "A template that shows all standard flake outputs";


  inputs = {
    # It is also possible to "inherit" an input from another input. This is useful to minimize
    # flake dependencies. For example, the following sets the nixpkgs input of the top-level flake
    # to be equal to the nixpkgs input of the nixops input of the top-level flake:
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # The value of the follows attribute is a sequence of input names denoting the path
    # of inputs to be followed from the root flake. Overrides and follows can be combined, e.g.
    nixops.url = "nixops";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    man-tools = {
      url = "path:/home/xgoffin/Code/man";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uds = {
      url = "path:/home/xgoffin/Code/uds";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helm-charts = {
      url = "path:/home/xgoffin/Code/helm-charts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tcurl = {
      url = "path:/home/xgoffin/Code/tcurl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
    nixosConfigurations.nixos= nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
    	./configuration.nix
            
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
        ({lib, pkgs, ...}: {
          environment.variables = {
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              pkgs.curl
              pkgs.libpq
              pkgs.sqlite
              pkgs.zlib
              pkgs.icu
              pkgs.openssl
              pkgs.libyaml
            ];
            PKG_CONFIG_PATH = "${pkgs.libyaml.dev}/lib/pkgconfig";
            CPATH = "${pkgs.libyaml.dev}/include";
          };
        })
      ];
    };
  };
}
