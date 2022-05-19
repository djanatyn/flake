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
      url = "github:djanatyn/ssbm-nix/1165c94ec029cef644a4d1a92fd391ce030c90f9";
    };

    emacs = {
      url = "github:nix-community/emacs-overlay";
    };

    fetch-followers = {
      url = "github:djanatyn/fetch-followers";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, fetch-followers, nix-ld, ssbm-nix, emacs, nixpkgs, darwin }@inputs: {
    overlay = final: prev: {
      fetch-followers = fetch-followers.packages.x86_64-linux.fetch-followers;

      netplay2021 = final.writeScriptBin "netplay2021" ''
        #!${final.stdenv.shell}

        exec ${final.slippi-netplay}/bin/slippi-netplay -e ~/melee/netplay2021.iso -u ~/slippi-config "$@"
      '';

      appimage-p-plus = final.appimageTools.wrapAppImage {
        src = /home/djanatyn/p-plus/Faster_Project_Plus-x86-64.AppImage;
        name = "appimage-p-plus";
        extraPkgs = pkgs: with pkgs; [ wrapGAppsHook gtk3 gmp vulkan-loader mesa_drivers mesa_glu mesa ];
      };

      p-plus = final.writeScriptBin "p-plus" ''
        #!${final.stdenv.shell}

        cd ~/p-plus
        exec ${final.appimage-p-plus}/bin/appimage-p-plus ~/p-plus/Faster_Project_Plus-x86-64.AppImage "$@"
      '';

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
          overlays = [ self.overlay ssbm-nix.overlay emacs.overlay ];
          config = { allowUnfree = true; };
        };
      in darwin.lib.darwinSystem { modules = [ ./work ]; };
    };

    darwinPackages = self.darwinConfigurations.work.pkgs;

    nixosConfigurations = let
      pkgs = import nixpkgs {
        overlays = [ self.overlay ssbm-nix.overlay emacs.overlay ];
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
