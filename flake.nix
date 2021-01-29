{
  inputs = {
    nixpkgs.url = "github:djanatyn/nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "/nixpkgs";
  };

  description = "nix configuration for djanatyn";

  outputs = { self, nixpkgs, home-manager }@inputs: {
    nixosConfigurations = let

      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      specialArgs = { inherit inputs pkgs; };

      # https://github.com/nix-community/home-manager#rollbacks
      # I have no idea what this snippet does, I just copied it from the flake
      # docs.
      # It creates a new module, which adds a new option, or in this case a
      # submodule (?). It inherits specialArgs and... sets super to the super
      # config? Hmm... *head scratching*
      hm-nixos-as-super = { config, ... }: {
        # Submodules have merge semantics, making it possible to amend
        # the `home-manager.users` submodule for additional functionality.
        options.home-manager.users = nixpkgs.lib.mkOption {
          type = nixpkgs.lib.types.attrsOf (nixpkgs.lib.types.submoduleWith {
            modules = [ ];
            # Makes specialArgs available to Home Manager modules as well.
            specialArgs = specialArgs // {
              # Allow accessing the parent NixOS configuration.
              super = config;
            };
          });
        };

        config = {
          home-manager = {
            useGlobalPkgs = true;
            backupFileExtension = "bak";
          };
        };
      };
    in {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          hm-nixos-as-super
          ./desktop
        ];
      };
    };
  };
}
