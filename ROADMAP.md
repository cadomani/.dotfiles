# Roadmap

Working document. Updated at the end of every stage.

Each stage introduces exactly one new failure domain, so that when something breaks there
is only one candidate. Stages are not merged.

---

## Done

### Stage 0 — Bootable minimum

**Installed 2026-07-27.** The machine boots NixOS from this flake. LUKS unlocks, TTY,
network, SSH, and `nixos-rebuild switch` all work from the installed system.
**No GUI, no NVIDIA driver, no home-manager.**

Running `nixos-system-desktop-26.11.20260711.e7a3ca8`, the same closure that had been built
ahead of time on the outgoing Arch machine. The repo lives at **`~/.dotfiles`** on the
desktop, matching its path on the MacBook so that a later nix-darwin host can share aliases
and module paths.

- `flake.nix` — nixpkgs `nixos-unstable` + disko, one `nixosConfiguration`: `desktop`
- `hosts/desktop/disko.nix` — GPT, 2G ESP, LUKS (`cryptroot`) → btrfs, subvolumes
  `/root` `/home` `/nix`, no swap
- `hosts/desktop/hardware-configuration.nix` — reconciled against `nixos-generate-config`
  on the ISO, no longer provisional
- `hosts/desktop/default.nix` — systemd-boot, systemd initrd, NetworkManager, locale/time,
  user, sshd (key-only), nix flakes + GC

Verified on the installed machine, in this order:

- [x] Arch `~/.ssh/id_ed25519` backed up off-machine before the wipe
- [x] `hardware-configuration.nix` reconciled. The generator reported **`vmd`** (Intel
      Volume Management Device), which the hand-written list had missed. The NVMe drives sit
      behind that controller, so without it the initrd finds no root disk and drops to an
      emergency shell. This was a guaranteed first-boot failure, and reconciling the file
      before installing is the only reason it was caught. Fixed in `3d6939c`.
- [x] disko touched the Samsung only. The Crucial's filesystem UUIDs (`BA99-B662`,
      `F6209AC6209A8CED`, `1A1A53D51A53AD0F`) were byte-identical before and after the run.
      That, not care, is the evidence Windows was never at risk.
- [x] `nixos-install`, reboot, LUKS passphrase accepted on a USB keyboard
- [x] `passwd` run on first login; the committed `initialPassword` no longer applies
- [x] `ssh carlos@<addr>` from the MacBook succeeds on key auth alone
- [x] `nixos-rebuild switch --flake ~/.dotfiles#desktop` succeeds from the installed system
- [x] Windows still boots, and is still first in the firmware boot order

---

## In progress

_Nothing. Stage 1 (home-manager plumbing) is next; see the Backlog._

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
  sops-nix-managed `hashedPasswordFile`. `passwd` was run on first login, so the value is
  inert on *this* machine, but it remains in git history and would apply to any future host
  built from this config.

- **Firmware boot order.** The firmware boots Windows first; NixOS is reached by picking
  **"Linux Boot Manager"** from the boot menu ("UEFI OS" is the fallback loader at
  `\EFI\BOOT\BOOTX64.EFI`, which also works). Reorderable in the firmware settings or with
  `efibootmgr -o`. Left alone because choosing at boot is not a burden and the current order
  fails safe toward the OS with data on it.
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
