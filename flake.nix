{
  inputs = {
    home.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:djanatyn/nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssbm-nix = {
      url = "github:djanatyn/ssbm-nix/e13633fddb0a571fe24a05128bb8f5bd217bba92";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, home, nix-ld, ssbm-nix, nixpkgs, darwin }@inputs: {
    overlay = final: prev: {
      crystal-melee = final.writeScriptBin "crystal-melee" ''
        #!${final.stdenv.shell}

        exec ${final.slippi-netplay}/bin/slippi-netplay -e ~/melee/diet-melee/DietMeleeLinuxPatcher/CrystalMelee_v1.0.1.iso -u ~/slippi-config "$@"
      '';

      crystal-melee-playback = final.writeScriptBin "crystal-melee-playback" ''
        #!${final.stdenv.shell}

        exec ${final.slippi-playback}/bin/slippi-playback -e ~/melee/diet-melee/DietMeleeLinuxPatcher/CrystalMelee_v1.0.1.iso -u ~/slippi-playback-config "$@"
      '';
    };

    homeConfigurations = {
      djanatyn = home.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/djanatyn";
        username = "djanatyn";
        configuration = { config, pkgs, ... }: {
          # home.stateVersion = "21.05";
          # programs.home-manager.enable = true;
        };
      };
    };

    darwinConfigurations = {
      work = let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ssbm-nix.overlay ];
          config = { allowUnfree = true; };
        };
      in darwin.lib.darwinSystem {
        modules = [ ./work ];
      };
    };

    darwinPackages = self.darwinConfigurations.work.pkgs;

    nixosConfigurations = {
      desktop = let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ssbm-nix.overlay ];
          config = { allowUnfree = true; };
        };
      in nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./desktop
          { nixpkgs = { inherit pkgs; }; }
          nix-ld.nixosModules.nix-ld
          ssbm-nix.nixosModule
        ];
      };
    };
  };
}
