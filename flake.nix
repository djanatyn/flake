{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssbm-nix = {
      url = "github:djanatyn/ssbm-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  description = "nix configuration for djanatyn";
  outputs = { self, nix-ld, ssbm-nix, nixpkgs }@inputs: {
    nixosConfigurations = {
      desktop = let
        pkgs = import nixpkgs {
          overlays = [ ssbm-nix.overlay ];
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
        ];
      };
    };
  };
}
