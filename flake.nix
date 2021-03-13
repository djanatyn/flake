{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";
  };

  description = "nix configuration for djanatyn";

  outputs = { self, nixpkgs }@inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./desktop
        ];
      };
    };
  };
}
