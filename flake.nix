{
  inputs = {
    nixpkgs.url = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssbm-nix = {
      url = "github:djanatyn/ssbm-nix/8ec53a5a1c02c48e3b5b52a1abd530d22e194fd7";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, nix-ld, ssbm-nix, nixpkgs, darwin }@inputs: {
    overlay = final: prev: {
      crystal-melee = final.writeScriptBin "crystal-melee" ''
        #!${final.stdenv.shell}

        exec ${final.slippi-netplay}/bin/slippi-netplay -e ~/melee/diet-melee/DietMeleeLinuxPatcher/CrystalMelee_v1.0.1.iso -u ~/slippi-config "$@"
      '';

      p-plus = final.appimageTools.wrapAppImage {
        src = /home/djanatyn/p-plus/Faster_Project_Plus-x86-64.AppImage;
        name = "p-plus";
        extraPkgs = pkgs: with pkgs; [ wrapGAppsHook gtk3 gmp ];
      };

      minecraft-server = prev.minecraft-server.overrideAttrs (old: rec {
        version = "1.18";

        src = prev.fetchurl {
          url = "https://launcher.mojang.com/v1/objects/3cf24a8694aca6267883b17d934efacc5e44440d/server.jar";
          sha1 = "1m248pncz9796zdihdw2d9mcjj34mwiw";
        };
      });
    };

    darwinConfigurations = {
      work = let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ssbm-nix.overlay ];
          config = { allowUnfree = true; };
        };
      in darwin.lib.darwinSystem { modules = [ ./work ]; };
    };

    darwinPackages = self.darwinConfigurations.work.pkgs;

    nixosConfigurations = let
      pkgs = import nixpkgs {
        overlays = [ self.overlay ssbm-nix.overlay ];
        config = { allowUnfree = true; };
      };
    in {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./desktop
          { nixpkgs = { inherit pkgs; }; }
          nix-ld.nixosModules.nix-ld
          ssbm-nix.nixosModule
        ];
      };

      vessel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./vessel
          { nixpkgs = { inherit pkgs; }; }
          nix-ld.nixosModules.nix-ld
        ];
      };
    };
  };
}
