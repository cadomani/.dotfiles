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
  };

  outputs =
    { nixpkgs, disko, ... }:
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          ./hosts/desktop/disko.nix
          ./hosts/desktop/hardware-configuration.nix
          ./hosts/desktop/default.nix
        ];
      };
    };
}
