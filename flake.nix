{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";
    nixpkgs.flake = true;

    home-manager.url = "github:nix-community/home-manager";
    home-manager.flake = true;
  };

  description = "nix configuration for djanatyn";

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import "${home-manager}/nixos")
          ./desktop
        ];
      };
    };
  };
}
