# Roadmap

Working document. Updated at the end of every stage.

Each stage introduces exactly one new failure domain, so that when something breaks there
is only one candidate. Stages are not merged.

---

## Done

_Nothing yet. The machine still runs Arch._

---

## In progress

### Stage 0 — Bootable minimum

Repo has a flake; the machine boots from it. LUKS unlocks, TTY, network, SSH, user.
**No GUI, no NVIDIA driver, no home-manager.**

Written, and **built to a complete system closure on the outgoing Arch machine**
(`nixos-system-desktop-26.11.20260711.e7a3ca8`, kernel 6.18.38) — so it compiles; what is
unproven is only that it boots. **Not yet installed.**

The install procedure, and the handoff to the agent who will run it, is **`INSTALL.md`**.

- `flake.nix` — nixpkgs `nixos-unstable` + disko, one `nixosConfiguration`: `desktop`
- `hosts/desktop/disko.nix` — GPT, 2G ESP, LUKS (`cryptroot`) → btrfs, subvolumes
  `/root` `/home` `/nix`, no swap
- `hosts/desktop/hardware-configuration.nix` — hand-written, **provisional**
- `hosts/desktop/default.nix` — systemd-boot, systemd initrd, NetworkManager, locale/time,
  user, sshd (key-only), nix flakes + GC

Remaining before this stage is Done:

- [ ] **Back up `~/.ssh/id_ed25519` off this machine.** The private key is not in the repo
      and dies with the Arch install. It is the key GitHub knows and the key in
      `authorizedKeys`.
- [ ] Regenerate `hardware-configuration.nix` on the ISO with
      `nixos-generate-config --no-filesystems --root /mnt` and diff against the hand-written
      one. Reconcile any difference before installing.
- [ ] Run disko (destructive — Samsung 990 PRO only), `nixos-install`, reboot.
- [ ] `passwd` — replace the placeholder `initialPassword`.
- [ ] Confirm `nixos-rebuild switch --flake .#desktop` succeeds **from the installed system**.
- [ ] Confirm Windows still boots from the firmware boot menu.

---

## Backlog

One line each: what and why, not how. Ordered roughly, not strictly.

### Next stages (from the handoff)

- **Stage 1 — home-manager plumbing.** Wire home-manager in as a NixOS module; a shell and
  git config built fresh. Verifiable from a TTY, which is the point: prove the plumbing
  before graphics can confuse the diagnosis. Neovim is *not* being ported — it will be
  written from scratch when we get there.
- **Stage 2 — NVIDIA.** Driver only, no compositor. RTX 5090 (Blackwell) forces
  `hardware.nvidia.open = true` and a recent driver branch; verify the nixpkgs attribute
  against upstream at the time, do not recall it.
- **Stage 3 — Niri session.** Greeter, compositor, portals, and the minimum surround:
  notifications, launcher, terminal. `hardware.nvidia.modesetting.enable` is mandatory or
  Niri will not start.
- **Stage 4+.** Audio (pipewire), fonts, real package set, sops-nix, lanzaboote, overlays.
  Prioritised by Carlos, one at a time.

### Deferred deliberately

- **Replace the placeholder password.** `initialPassword = "changeme"` is committed to a
  *public* repo. SSH is key-only so it is not remotely exploitable, but it should become a
  sops-nix-managed `hashedPasswordFile`. Until then: change it with `passwd` after install.
- **zram.** The chosen answer to memory pressure, since we carved no swap. One option, no
  disk-layout change. Not needed at 128 GB until proven otherwise.
- **`/var/log` subvolume, and impermanence.** Adding a btrfs subvolume later needs no
  repartitioning, so there was no reason to create one speculatively. Revisit if we ever
  want to roll back `/` without losing logs.
- **Windows chainload entry in systemd-boot.** `boot.loader.systemd-boot.windows.*` may or
  may not exist in our pinned nixpkgs — unverified, because nothing depends on it. The
  firmware boot menu selects Windows regardless.
- **Secure Boot / lanzaboote.** Currently disabled in firmware. `boot.initrd.systemd.enable`
  is already on, which is lanzaboote's prerequisite.
- **`nix.settings.auto-optimise-store`.** Store deduplication. Cheap, but nothing needs it
  yet.
- **Flake update cadence.** `nixos-unstable` only moves when `nix flake update` is run.
  Decide how often, and whether to pin per-stage.
