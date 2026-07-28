{
  description = "NixOS configuration";

  inputs = {
    # nixos-unstable: rolling, closest to the Arch experience. Pinned by flake.lock,
    # so "unstable" only moves when we run `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # disko: declarative partitioning. Owns fileSystems/swapDevices.
    disko = {
      url = "github:nix-community/disko";
      # Build disko against our nixpkgs rather than letting it pull a second copy.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager: declarative user environment (dotfiles, shell, git).
    #
    # No `ref`, so this tracks the default branch, `master`. That is deliberate:
    # home-manager develops against nixpkgs-unstable and cuts release-XX.XX branches to
    # match NixOS releases. We track nixos-unstable, so master is the branch whose options
    # match our nixpkgs. Pairing a release branch with unstable nixpkgs is a common source
    # of option-does-not-exist errors. Pinned by flake.lock either way.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./hosts/desktop/disko.nix
          ./hosts/desktop/hardware-configuration.nix
          ./hosts/desktop/default.nix
        ];
      };
    };
}
