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

    # The login shell recorded in /etc/passwd. home-manager writes ~/.zshrc but has no way
    # to edit /etc/passwd, so without this line the login shell stays bash and none of that
    # config is ever sourced. Paired with programs.zsh.enable below.
    shell = pkgs.zsh;

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

    # SSH is key-only (see below), so this list is the *entire* set of ways in over the
    # network. Get it wrong and the only way back is the physical console.
    #
    # This is the MacBook Pro's key. It is deliberately the only one: the key this repo
    # previously carried belonged to the Arch install that this machine's disk is about to
    # stop being, so nothing would hold its private half in a position to connect *inward*
    # to this host. A dead key in authorizedKeys is not a fallback, it is just a key.
    #
    # Note this is unrelated to any key the desktop later uses to push to GitHub -- that is
    # an outbound credential and does not belong here.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgc8df1KoG0THI4ddSDowLgQdoorJajZ6eGTMtB8OxD Mac"
    ];
  };

  # ------------------------------------------------------------------ shell
  # The NixOS half of the zsh setup, and it is not optional. This installs zsh system-wide
  # and registers it in /etc/shells, which is what makes the `shell` line above legal: a
  # login shell absent from /etc/shells is refused. It also arranges for /etc/zshrc, where
  # NixOS puts the environment every shell on this system needs.
  programs.zsh.enable = true;

  # Link share/zsh out of every system package so completion works for system commands too.
  # Without it `systemctl <tab>` finds nothing while completion for user packages works
  # perfectly, which is a confusing shape for the problem to take. Recommended by
  # home-manager's own enableCompletion documentation.
  environment.pathsToLink = [ "/share/zsh" ];

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

    # Terminfo for Ghostty, the terminal this machine is driven from over SSH. Ghostty sets
    # TERM=xterm-ghostty, and a host with no matching terminfo entry has no description of
    # the terminal's capabilities, so zsh's line editor miscomputes cursor movement and
    # echoes characters twice. This is the terminfo output alone, not the terminal, and
    # installing it on remote hosts is what the nixpkgs ghostty package itself recommends.
    ghostty.terminfo
  ];

  # ------------------------------------------------------------------ home-manager
  # Wired in as a NixOS module rather than run standalone, so that `nixos-rebuild switch`
  # builds the system and the home environment as one unit. Either both land or neither
  # does, and there is no second command to remember.
  #
  # Everything user-facing lives in ../../home/carlos.nix, which holds no NixOS options so
  # that a nix-darwin host can import it unchanged later. This block is the seam between
  # the two, and it is the only part that knows it is running on NixOS.
  home-manager = {
    # Use the system's nixpkgs instead of letting home-manager instantiate its own. Without
    # this a single build evaluates nixpkgs twice, which is slower and lets system and user
    # packages drift onto different builds of the same library.
    useGlobalPkgs = true;

    # Install user packages into /etc/profiles/per-user/carlos, owned by the system
    # generation, rather than ~/.nix-profile. This is what makes `nixos-rebuild --rollback`
    # take the home environment back with it instead of leaving it ahead of the system.
    useUserPackages = true;

    # On activation home-manager refuses to overwrite a file it does not already manage, and
    # reports it as an error about a single path that reads like a bug in home-manager.
    # Renaming the offender aside makes that a non-event. zsh is the likely trigger: started
    # with no ~/.zshrc it offers to write one, after which home-manager finds a file it did
    # not put there.
    backupFileExtension = "hm-bak";

    users.carlos = ../../home/carlos.nix;
  };

  # ------------------------------------------------------------------ state
  # Not a version to keep current -- do not "update" it. It records which release's
  # stateful defaults (database layouts, service data formats) this system was built
  # against, so that upgrading NixOS does not silently migrate data out from under a
  # service. It stays at the release we installed from, forever.
  system.stateVersion = "26.11";
}
