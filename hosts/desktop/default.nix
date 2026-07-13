# System configuration for `desktop`.
#
# Stage 0 only: enough to boot, unlock, get a TTY, reach the network, and rebuild itself.
# No GUI, no NVIDIA, no home-manager. Those are stages 2, 3 and 1 respectively -- each one
# introduces exactly one new thing that can break.
{ pkgs, ... }:
{
  # ------------------------------------------------------------------ boot
  boot.loader.systemd-boot.enable = true;

  # Every generation copies its kernel and initrd into the ESP. Left unbounded these
  # accumulate until the ESP is full, at which point rebuilds fail at the copy step --
  # typically weeks later, with no hint that space is the problem. 10 generations is a
  # comfortable rollback window that a 2G ESP holds easily.
  boot.loader.systemd-boot.configurationLimit = 10;

  # systemd-boot registers itself in EFI NVRAM, which requires write access to efivars.
  boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd inside the initrd rather than the old shell-script initrd. Two payoffs:
  # a real LUKS passphrase prompt (retries, correct keymap, sane failure), and lanzaboote
  # -- secure boot, on the roadmap -- requires it. Switching initrd implementations later,
  # on a machine whose root you cannot unlock, is a bad afternoon. Cheap to set now.
  boot.initrd.systemd.enable = true;

  # ------------------------------------------------------------------ networking
  networking.hostName = "desktop";

  # NetworkManager is fully usable from a TTY via nmcli, and is what a desktop session will
  # expect in stage 3 -- so it is the one choice here that does not get replaced later.
  networking.networkmanager.enable = true;

  # ------------------------------------------------------------------ time & locale
  time.timeZone = "America/Chicago";

  # Windows insists on treating the RTC as local time. If Linux treats the same clock as
  # UTC, every switch between the two operating systems shifts the clock by our UTC offset.
  # Making Linux agree with Windows is the side that actually works.
  time.hardwareClockInLocalTime = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ------------------------------------------------------------------ users
  # `users.mutableUsers` is left at its default (true), so `passwd` works normally.
  users.users.carlos = {
    isNormalUser = true;
    description = "Carlos Domani";
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # bring links up/down without sudo
    ];

    # TEMPORARY, AND NOT A SECRET.
    #
    # This string is world-readable in the nix store and in git history forever. It exists
    # only so that the very first TTY login is guaranteed to work -- which is precisely
    # stage 0's success criterion, and not something to discover is broken at 1am with no
    # shell. `initialPassword` applies only at account creation, so:
    #
    #     run `passwd` on first login and this value stops mattering.
    #
    # It is deliberately not the real password. Replacing this with a sops-nix-managed
    # `hashedPasswordFile` is a tracked backlog item.
    initialPassword = "changeme";

    # SSH is key-only (see below), so this key is the sole way in over the network.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKSFCzQLf27gDx707NBDAuzjZrcdyEGxTbh2KheldnV Arch"
    ];
  };

  # ------------------------------------------------------------------ ssh
  services.openssh = {
    enable = true;
    settings = {
      # Keys only. An sshd that accepts passwords turns the placeholder above into a real
      # remote vulnerability; this is what keeps that from ever being true.
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ------------------------------------------------------------------ nix
  # Without this, `nixos-rebuild --flake` is not a command this system understands.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # The store only ever grows. Collect weekly, but keep a 30-day floor so that rolling back
  # to a generation from last week is still possible -- GC is what deletes the thing you
  # want to roll back *to*.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ------------------------------------------------------------------ packages
  # Deliberately two. Stage 0 needs exactly enough to rebuild itself and to repair a broken
  # config from a TTY; everything else belongs to a later stage that can justify it.
  environment.systemPackages = with pkgs; [
    git # `nixos-rebuild --flake .` cannot read a flake in a git repo without it
    vim # edit a config that will not evaluate, before an editor has been configured
  ];

  # ------------------------------------------------------------------ state
  # Not a version to keep current -- do not "update" it. It records which release's
  # stateful defaults (database layouts, service data formats) this system was built
  # against, so that upgrading NixOS does not silently migrate data out from under a
  # service. It stays at the release we installed from, forever.
  system.stateVersion = "26.11";
}
