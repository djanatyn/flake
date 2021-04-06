{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssbm-nix = {
      url = "github:djanatyn/ssbm-nix/e97b509b4b6167711b91d409448630d7e847e4f9";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, nix-ld, ssbm-nix, nixpkgs }@inputs: {
    overlay = final: prev: {
      crystal-melee = final.writeScriptBin "crystal-melee" ''
        #!${final.stdenv.shell}

        exec ${final.slippi-netplay}/bin/slippi-netplay -e ~/melee/diet-melee/DietMeleeLinuxPatcher/CrystalMelee_v1.0.1.iso -u ~/slippi-config
      '';
    };

    nixosConfigurations = {
      desktop = let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ssbm-nix.overlay ];
          config = {
            allowUnfree = true;
          };
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
