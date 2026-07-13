# Install runbook / agent handoff

**You are the second agent on this project.** The first one authored stage 0 on the Arch
install that this procedure destroys, and could not survive the wipe. This file is how the
work continues.

## Read these first, in this order

1. **`HANDOFF.md`** — Carlos's own brief. The working agreement in it is still in force and
   is not mine to relax: one stage at a time, no scaffolding ahead, explain every option
   before adding it, smallest diff that advances the stage, ask before anything destructive,
   verify fast-moving things against upstream instead of recalling them.
2. **`DECISIONS.md`** — every non-obvious choice, with what was rejected and why. Read it
   before you "improve" anything. Several entries exist specifically to stop a future agent
   from undoing something load-bearing.
3. **`ROADMAP.md`** — Done / In progress / Backlog. Update it at the end of every stage.
4. This file.

One amendment to `HANDOFF.md` you must know about: it says "keep nvim, drop the rest."
**Carlos revised that — nothing is ported, neovim included.** He will write a new neovim
config from scratch when stage 1 reaches it. So the `mkOutOfStoreSymlink` machinery that
`HANDOFF.md` describes is not needed. The old dotfiles remain on `origin/main` if he ever
wants to crib from them.

---

## State of play

Stage 0 is **written, evaluated, and built — but not installed.** On the outgoing Arch
machine, `nixosConfigurations.desktop` built all the way to a complete system closure
(`nixos-system-desktop-26.11.20260711.e7a3ca8`, kernel 6.18.38). So the config compiles;
what is unproven is only that it *boots*.

Verified by evaluation, not by memory:

- disko derives `/` (`subvol=/root`), `/home`, `/nix` on `/dev/mapper/cryptroot`, all
  btrfs with `compress=zstd,noatime`; `/boot` vfat, `umask=0077`
- exactly one LUKS device, `cryptroot`, with `allowDiscards` reaching the boot-time unlock
- `swapDevices` is empty, deliberately
- Intel microcode on; systemd initrd on; ESP capped at 10 generations

Inputs are pinned: nixpkgs `e7a3ca8092b6` (2026-07-11), disko `ff8702b4de27` (2026-06-11).

### Hardware

| | |
|---|---|
| CPU | Intel i9-13900K (Raptor Lake) |
| RAM | 128 GB |
| GPU | **NVIDIA RTX 5090 (GB202, Blackwell)** |
| Firmware | UEFI, Secure Boot currently disabled |

---

## THE SAFETY RULE

There are two NVMe drives. **One of them has Windows on it and must survive.**

| Drive | Serial | Role |
|---|---|---|
| Samsung SSD 990 PRO 2TB | `S7KHNJ0X706305T` | **NixOS target — will be destroyed** |
| Crucial CT2000P5PSSD8 | `23143FB5191D` | **Windows — must not be touched** |

`hosts/desktop/disko.nix` names the Samsung by `/dev/disk/by-id/`, and names the Crucial
nowhere at all. That is the safety property: disko only touches disks it is told about.

**Never use `/dev/nvme0n1` / `/dev/nvme1n1` in any command.** Kernel enumeration is
probe-order and is not stable across boots. The wrong node formats Windows.

Before the destructive step, re-verify on the ISO that the serial above still identifies the
Samsung — and if anything at all disagrees with this table, **stop and ask Carlos.** Do not
resolve the discrepancy by inference.

---

## Runbook

### 1. Before the machine is wiped (do this on Arch, while it still boots)

- [ ] **Back up `~/.ssh/id_ed25519` (the private key) somewhere off this machine.** It is
      not in the repo. It is the key GitHub authenticates with and the key in
      `authorizedKeys`. Losing it is annoying, not fatal — but recovering costs an hour.

### 2. On the installer ISO

Boot the NixOS minimal ISO (x86_64) from USB. The live user is `nixos`; sudo needs no
password. Wired ethernet should come up on DHCP.

```sh
# Tools. claude-code is packaged in nixpkgs (2.1.206 in our pinned rev).
nix-shell -p git

git clone -b nixos https://github.com/cadomani/.dotfiles.git ~/dotfiles
cd ~/dotfiles
```

**Re-verify the drives. This is the gate.**

```sh
lsblk -o NAME,SIZE,MODEL,SERIAL
ls -l /dev/disk/by-id/ | grep nvme
```

Confirm the Samsung is `S7KHNJ0X706305T` and the Crucial is `23143FB5191D`, and get
Carlos's explicit confirmation before continuing.

### 3. Reconcile `hardware-configuration.nix`

It was **hand-written** — `nixos-generate-config` does not exist on Arch, so it could not be
generated. This is the first chance to check it against reality. It runs on the live ISO and
needs no `/mnt`, so do it *before* anything destructive:

```sh
sudo nixos-generate-config --no-filesystems --dir /tmp/gen
diff /tmp/gen/hardware-configuration.nix hosts/desktop/hardware-configuration.nix
```

`--no-filesystems` is mandatory. disko already defines `fileSystems` and `swapDevices`; a
second definition is a duplicate-definition eval error whose message does not point at its
own cause.

Take any **hardware facts** the generator found that the hand-written file lacks (typically
extra `boot.initrd.availableKernelModules`). Keep the existing comments — they explain why
each module is there, and the generator explains nothing. Never accept `fileSystems` or
`swapDevices` from it.

Then re-check that it still evaluates, and commit any change (flakes only see git-tracked
files, so an uncommitted edit is invisible to the next command):

```sh
nix --extra-experimental-features 'nix-command flakes' \
  eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
git commit -am "fix: reconcile hardware-configuration.nix with nixos-generate-config"
```

### 4. Partition — DESTRUCTIVE, ask first

This erases the Samsung. Get a clear go-ahead from Carlos immediately before running it.

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1 -- \
  --mode destroy,format,mount \
  --flake .#desktop
```

`--mode destroy,format,mount` is the current spelling (the old `--mode disko` is
deprecated). Disko has a built-in destroy safety check; there is a flag to skip it —
**do not pass it.**

It will prompt for the LUKS passphrase interactively. Nothing secret is written to the repo
or the store.

Verify before proceeding:

```sh
lsblk -f
mount | grep /mnt     # expect /mnt, /mnt/home, /mnt/nix, /mnt/boot
```

### 5. Install

```sh
sudo nixos-install --flake .#desktop
```

It prompts for a **root** password at the end — set one; it is the recovery path.
`carlos` already has `initialPassword = "changeme"` from the config.

```sh
sudo reboot
```

Remove the USB. Pick the Samsung's NixOS entry **from the firmware boot menu** — there is
deliberately no GRUB and no os-prober, and the Windows ESP is never mounted.

### 6. First boot — this is what "stage 0 done" means

- [ ] LUKS prompt appears and accepts the passphrase (a USB keyboard working here is what
      `usbhid` / `xhci_pci` in the initrd are for)
- [ ] Log in as `carlos` / `changeme`, then **immediately `passwd`**
- [ ] Network is up (`ping -c1 github.com`)
- [ ] Restore `~/.ssh/id_ed25519`, `chmod 600`, and switch the remote to SSH so you can push
- [ ] Clone the repo to its permanent home and rebuild **from the installed system** — this
      is the actual done-criterion, not the install:

      git clone -b nixos git@github.com:cadomani/.dotfiles.git ~/dev/dotfiles
      sudo nixos-rebuild switch --flake ~/dev/dotfiles#desktop

- [ ] **Reboot into Windows from the firmware menu** and confirm it still works
- [ ] Move stage 0 to `Done` in `ROADMAP.md`, commit, push

---

## Then: stage 1, and not a line more

Stage 1 is home-manager plumbing, wired in as a NixOS module, verifiable **entirely from a
TTY**. That is the whole point of its ordering: prove the home-manager plumbing before the
graphics stack can confuse the diagnosis. A shell and a git config, built fresh. Nothing
ported.

Keep the home-manager modules free of NixOS-only references — Carlos wants to reuse them
under nix-darwin on an M1 mini later, and that stays cheap only if the coupling never
happens in the first place.

### Landmines waiting in later stages

- **`nixpkgs.config.allowUnfree` is deliberately absent.** The NVIDIA driver will not
  evaluate without it. It is not an oversight — stage 0 does not need it, so it is not there.
- **RTX 5090 is Blackwell.** `hardware.nvidia.open = true` is not a preference here, it is
  the only option: there is no proprietary kernel module path for this generation, and it
  needs a recent driver branch. Verify the nixpkgs driver attribute against upstream when
  you get there. Do not recall it.
- **`hardware.nvidia.modesetting.enable = true`** is mandatory for any Wayland compositor.
  Its absence is the cause of most "NVIDIA + Wayland is broken" reports. Niri will not start.
- **`hardware.graphics` vs `hardware.opengl`** was renamed and both names appear in guides
  you will find. Check which is current in our pinned nixpkgs.
- **niri-flake** (`github:sodiboo/niri-flake`) module attribute names move. Read its README
  at the time you write the module, not from memory.
