# Decisions

Append-only. One entry per non-obvious choice: what we chose, what we rejected, why.

The point of this file is that in eight months neither Carlos nor a future agent
re-litigates a settled question, or "cleans up" something load-bearing.

---

## 2026-07-12 — Target disk identified by model+serial, not kernel name

**Chose:** `/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7KHNJ0X706305T` (Samsung 990 PRO
2TB) as the install target. The Windows disk (Crucial CT2000P5PSSD8, serial `23143FB5191D`)
is not named anywhere in this repo.

**Rejected:** `/dev/nvme1n1`. Kernel enumeration order is probe-order and is not stable
across boots; the wrong node here formats Windows.

**Also rejected:** the `nvme-eui.002538474140464d` and `..._S7KHNJ0X706305T_1` aliases. All
three symlinks resolve to the same physical device (verified directly against
`ls -l /dev/disk/by-id/`). The unsuffixed model+serial form was chosen because it is the
one a human can check against `lsblk -o MODEL,SERIAL`, or against the label on the drive,
without indirection. For the single string in this repo that decides which disk gets
destroyed, human-verifiability beats brevity.

---

## 2026-07-12 — No swap device

**Chose:** no swap partition and no swapfile.

**Rejected:** a swapfile sized for hibernation. On LUKS + btrfs that needs a `resume_offset`
derived from `btrfs inspect-internal map-swapfile`, which is fragile and easy to silently
invalidate.

**Rationale:** 128 GB of RAM, and this is a desktop that suspends to RAM rather than
hibernating — and suspend-to-RAM requires no swap whatsoever. A swap device we never page
into is a partition we must reason about forever for no benefit. If memory pressure ever
materialises, zram is the answer and it needs no change to the disk layout.

---

## 2026-07-12 — Three btrfs subvolumes, not more

**Chose:** `/root` → `/`, `/home` → `/home`, `/nix` → `/nix`. All with `compress=zstd`
and `noatime`.

**Rejected (for now):** `/var/log`, and an impermanence-style `@persist`.

**Rationale:** a subvolume is not a partition. Adding one later is `btrfs subvolume create`
plus a config line — no repartitioning, no reinstall. Because the cost of deferring is
approximately zero, creating subvolumes that nothing currently uses would be pure
speculation. `/nix` is split out because it is large and wholly reproducible, so snapshots
or rollbacks of `/` should not drag the store with them.

---

## 2026-07-12 — NixOS gets its own ESP on its own disk; systemd-boot; no GRUB

**Chose:** a fresh 2G ESP on the Samsung, `systemd-boot`, and the firmware boot menu to
choose between operating systems.

**Rejected:** GRUB with `os-prober`, and mounting the existing Windows ESP.

**Rationale:** the Windows ESP is never mounted, never in fstab, never written. That makes
"a Windows update broke my bootloader" and "a NixOS rebuild broke Windows" both structurally
impossible rather than merely unlikely. os-prober works until it doesn't, and its failure
mode is an unbootable machine.

**2G, not the customary 512M:** each generation copies a kernel and initrd into the ESP.
A full ESP fails the rebuild at the copy step, typically weeks later, with an error that
never mentions space. Paired with `boot.loader.systemd-boot.configurationLimit = 10`.

---

## 2026-07-12 — `hardware-configuration.nix` hand-written, and provisional

**Chose:** hand-author it, with every line justified, and mark it provisional.

**Rejected:** generating it — impossible, since `nixos-generate-config` does not exist on
the Arch system this was authored from.

**Rationale:** the flake must evaluate *before* we boot the ISO, which is what lets us catch
config errors while we still have a working machine. That requires the file to exist. It
will be regenerated with `nixos-generate-config --no-filesystems --root /mnt` on the ISO and
diffed before install; the `--no-filesystems` flag is mandatory, because disko already
defines `fileSystems` and `swapDevices` and a duplicate definition produces an eval error
that does not point at its own cause.

---

## 2026-07-12 — `boot.initrd.systemd.enable = true` from the start

**Chose:** the systemd initrd, immediately, rather than the legacy shell initrd.

**Rationale:** it produces a real LUKS passphrase prompt (retries, correct keymap, sane
failure behaviour), and lanzaboote — secure boot, on the backlog — requires it. Switching
initrd implementations later, on a machine whose root you cannot unlock, is a much worse
afternoon than setting one option now.

---

## 2026-07-12 — Placeholder password committed to a public repo

**Chose:** `users.users.carlos.initialPassword = "changeme"`, with SSH set to key-only
(`PasswordAuthentication = false`).

**Rejected:** setting no password and relying on the root password prompt during
`nixos-install`, then `passwd carlos` from a root shell. This commits no string at all and
was the close runner-up.

**Rationale:** stage 0's entire success criterion is "I get a TTY as my user". Guaranteeing
the first login works — rather than discovering at 1am that it doesn't, with no shell —
is worth publishing a string that is explicitly not a secret and cannot be used remotely.
`initialPassword` applies only at account creation, so `passwd` on first login retires it.

**This is a known debt, not an oversight:** the repo is public, so the string is public, and
if it is never changed then anyone with physical access has a login. Tracked in ROADMAP.md;
the destination is a sops-nix-managed `hashedPasswordFile`.

---

## 2026-07-12 — All existing dotfiles dropped, including neovim

**Chose:** start from nothing. No config is ported.

**Supersedes** the handoff document, which said "keep nvim, drop the rest" — Carlos revised
this: the neovim config will also be rewritten from scratch when stage 1 reaches it.

**Rationale:** stow is being retired entirely, and stow and home-manager are both symlink
farmers — running both against `~/.config` means neither clearly owns anything, which is the
ambiguity this migration exists to remove. Nothing is lost: the old tree, neovim included,
remains on `origin/main` and is recoverable from git history at any time.

**Consequence:** the `mkOutOfStoreSymlink` machinery the handoff described for neovim is not
needed in stage 1, which makes that stage smaller. It may return later, on its own merits,
if the fast edit loop for an editor config turns out to matter.

---

## 2026-07-12 — nixpkgs `nixos-unstable`, `stateVersion = "26.11"`

**Chose:** track `nixos-unstable`. Locked at `e7a3ca80` (2026-07-11); disko at `ff8702b4`
(2026-06-11).

**Rationale:** closest to the rolling Arch experience being left behind. "Unstable" is a
misnomer in a flake — the lockfile pins it, so it only moves when `nix flake update` runs.

**`stateVersion = "26.11"`** was read from the pinned nixpkgs (`lib.trivial.release`), not
recalled. It is not a version to keep current: it records which release's stateful defaults
this system was built against, and it stays where it is forever.
