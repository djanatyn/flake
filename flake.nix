{
  inputs = {
    home.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:djanatyn/nixpkgs";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssbm-nix = {
      url = "github:djanatyn/ssbm-nix/5306587739596d50d5b42b38b9776cd4fd3b18b7";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, home, nix-ld, ssbm-nix, nixpkgs }@inputs: {
    overlay = final: prev: {
      crystal-melee = final.writeScriptBin "crystal-melee" ''
        #!${final.stdenv.shell}

        exec ${final.slippi-netplay}/bin/slippi-netplay -e ~/melee/diet-melee/DietMeleeLinuxPatcher/CrystalMelee_v1.0.1.iso -u ~/slippi-config
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
