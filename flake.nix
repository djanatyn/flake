{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssbm-nix = {
      url = "github:djanatyn/ssbm-nix/3896cac81722975dbbc1e6ba0e2904e2fe1b48b4";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, nix-ld, ssbm-nix, nixpkgs, darwin }@inputs: {
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
