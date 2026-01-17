{
  description = "Slipstream Testbed";

  inputs = {
    # Default to the June 2025 branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake version for command-not-found
    flake-programs-sqlite.url = "github:wamserma/flake-programs-sqlite";
    flake-programs-sqlite.inputs.nixpkgs.follows = "nixpkgs";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Dank Material Shell
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-monitor = {
    #   url = "github:antonjah/nix-monitor";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Home-manager, used for managing user configuration
    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      disko,
      # nix-monitor,
      #nixpkgs-pinned,
      #nixpkgs-stable,
      #nixpkgs-last-stable,
      home-manager,
      ...
    }:
    let
      mySpecialArgs = {
        inherit inputs;
      };

      generic-system = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mySpecialArgs;
        modules = [
          disko.nixosModules.disko
          ./nixos/disko.nix

          inputs.flake-programs-sqlite.nixosModules.programs-sqlite

          # nix-monitor.nixosModules.default

          ./nixos/hardware-configuration.nix
          ./nixos/configuration.nix
          ./nixos/packages.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = mySpecialArgs;
            home-manager.users.slipstream-testbed = import ./nixos/slipstream-home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    in
    {
      #, hyprland, ... }: {
      nixosConfigurations.slipstream-testbed = generic-system;
    };
}
