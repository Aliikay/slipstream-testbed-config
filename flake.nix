{
  description = "Slipstream Testbed";

  inputs = {
    # Default to the June 2025 branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Latest unstable branch of nixos
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # stylix to theme the entire system
    stylix.url = "github:danth/stylix/release-25.11";

    # Flake version for command-not-found
    flake-programs-sqlite.url = "github:wamserma/flake-programs-sqlite";
    flake-programs-sqlite.inputs.nixpkgs.follows = "nixpkgs";

    # Home-manager, used for managing user configuration
    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-25.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unstable home manager
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      #nixpkgs-pinned,
      #nixpkgs-stable,
      #nixpkgs-last-stable,
      home-manager,
      ...
    }:
    let
      mySpecialArgs = {
        inherit inputs;
        # To use packages from nixpkgs-unstable,
        # we configure some parameters for it first
        #pkgs-stable = import nixpkgs-stable {
        # Refer to the `system` parameter from
        # the outer scope recursively
        #  inherit inputs;
        #  system = "x86_64-linux";
        #  config.allowUnfree = true;
        #};

        #pkgs-last-stable = import nixpkgs-last-stable {
        # Refer to the `system` parameter from
        # the outer scope recursively
        #  inherit inputs;
        #  system = "x86_64-linux";
        #  config.allowUnfree = true;
        #};

        pkgs-unstable = import nixpkgs-unstable {
          # Refer to the `system` parameter from
          # the outer scope recursively
          inherit inputs;
          system = "x86_64-linux";
          config.allowUnfree = true;
        };

        #pkgs-pinned = import nixpkgs-pinned {
        #  inherit inputs;
        #  system = "x86_64-linux";
        #  config.allowUnfree = true;
        #};
      };

      generic-system = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mySpecialArgs;
        modules = [

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
