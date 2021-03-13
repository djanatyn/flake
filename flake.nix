{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  description = "nix configuration for djanatyn";

  outputs = { self, nix-ld, nixpkgs }@inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./desktop
          nix-ld.nixosModules.nix-ld
        ];
      };
    };
  };
}
