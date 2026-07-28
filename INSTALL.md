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

> **This runbook was executed on 2026-07-27 and the install is complete.** Stage 0 is done;
> see `ROADMAP.md`. What follows is kept as the record of how it was done. Read *What
> actually happened* first, because six things diverged from it.

On the outgoing Arch machine, `nixosConfigurations.desktop` had already built to a complete
system closure (`nixos-system-desktop-26.11.20260711.e7a3ca8`, kernel 6.18.38), and that is
the closure now running on the machine.

### What actually happened

1. **`hardware-configuration.nix` was missing `vmd`.** The reconciliation in step 3 was not
   a formality: `nixos-generate-config` reported `vmd` (Intel Volume Management Device) and
   the hand-written list lacked it. The NVMe drives sit behind that controller, so the
   initrd would have found no root disk and dropped to an emergency shell, with an error
   naming a missing device rather than a missing module. Fixed in `3d6939c`. This was the
   only difference between the two files.

2. **The graphical ISO does not work on this machine.** Option B was tried first and failed
   the way it warned it might: the RTX 5090 produced a hung NixOS splash and never reached a
   desktop. Option A (minimal ISO, SSH in from the MacBook) worked with no trouble at all.
   Blackwell plus nouveau is now a confirmed non-starter rather than a suspicion. Do not
   spend time on the graphical ISO here.

3. **`nixos-install` needs flakes enabled explicitly.** The ISO's nix does not enable them,
   and `nixos-install` shells out to nix internally where `--extra-experimental-features`
   does not reach. Set it in the environment instead, as step 5 now shows.

4. **`--dry-run` prints a store path, not the script.** To audit what disko will do you have
   to read the file it points at. Step 4 now shows how.

5. **The repo lives at `~/.dotfiles`**, not `~/dev/dotfiles`, matching its path on the
   MacBook so a later nix-darwin host can share aliases and module paths.

6. **Firmware boots Windows first, and the NixOS entry is called "Linux Boot Manager."**
   Not "NixOS". There is also a "UEFI OS" entry, which is the fallback loader at
   `\EFI\BOOT\BOOTX64.EFI` and also works.

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

### 1. Before the machine is wiped

- [x] The Arch machine's `~/.ssh/id_ed25519` has been backed up off-machine.

Keep two different keys straight, because they do two unrelated jobs:

- **The MacBook Pro's key** is in `users.users.carlos.openssh.authorizedKeys.keys`. It is
  the *only* entry, and since sshd here is key-only, it is the entire inbound attack surface
  and the entire inbound access path. Carlos drives this machine from the MacBook.
- **The backed-up Arch key** is an *outbound* credential — the one GitHub knows. It has no
  business in `authorizedKeys` (nothing would hold its private half in a position to
  connect inward to this host), and it was removed from there.

### 2. On the installer ISO — getting a shell for the agent

**The agent runs on the target machine, where the disks are.** That is the only part of this
that is not negotiable: an agent reasoning about `lsblk` output through a remote shell,
one `ssh` invocation at a time, is exactly the indirection you do not want adjacent to a
destructive command. *How* you get that shell is a genuine choice, and both options below
are fine. Everything from step 3 onward is identical either way.

The relevant constraint is that **Claude Code has to authenticate**, which wants a browser
and a terminal you can paste into. That, not capability, is what separates these.

#### Option A — Minimal ISO, SSH in from the MacBook

Verified against our pinned nixpkgs (`nixos/modules/profiles/installation-device.nix`):
sshd **is** enabled on the ISO, and the console **autologins** as `nixos` with passwordless
sudo — but `nixos` and `root` both have **empty passwords**, and sshd refuses to
authenticate an empty password. So SSH does not work until someone changes that, and that
someone has to be at the physical console. Which is free: booting the USB and picking the
firmware entry already requires standing there.

At the (autologged-in) console:

```sh
passwd              # any throwaway password; it lives only as long as the ISO session
ip -brief addr      # note the address
```

Then from the MacBook, `ssh nixos@<address>`, and run the agent inside that session.

**Why this is the safer default:** it has no dependency on the GPU whatsoever. You get a
real terminal — scrollback, copy/paste, a browser one window away for the login flow — and
the graphics stack cannot participate in anything going wrong. That is the same instinct the
whole stage ordering is built on.

#### Option B — Graphical (GNOME) ISO, agent directly on the machine

Fully self-contained: no SSH, no `passwd`, no second machine. The graphical ISO ships
**Firefox and GNOME Terminal** (verified: `installation-cd-graphical-base.nix` installs
`firefox`), so Claude Code's browser login works right there, and you have a terminal with
working copy/paste and scrollback. Open a terminal and go straight to step 3.

**The caveat, stated honestly:** this machine has an **RTX 5090**, and the ISO has no NVIDIA
driver — it will fall back to nouveau or to the plain EFI framebuffer. GNOME will most
likely come up software-rendered and slow, which is entirely good enough for a terminal and
a browser. But "most likely" is doing real work in that sentence: Blackwell is new, and this
is unverified. If the graphical ISO will not give you a desktop, do not fight it — fall back
to Option A, which cannot have this problem.

#### Not recommended — minimal ISO, agent on the bare TTY

It works, but a bare Linux TTY has no browser, no clipboard, and no scrollback. You would be
reading a login URL off the screen, typing it into another device by hand, and typing the
resulting code back. Then reading agent output with no way to scroll up. Choose A or B.

#### Rejected — a custom ISO with the key pre-baked

Would remove the `passwd` step in Option A. Not worth it: a new artifact to build, flash and
debug, to save one command on a machine you are already standing in front of.

#### Tools and repo

`claude-code` is packaged in nixpkgs (2.1.206 in our pinned rev), so the agent does not need
npm, node, or an installer script — it is one `nix-shell` away on either path:

```sh
nix-shell -p git claude-code

git clone -b nixos https://github.com/cadomani/.dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Clone over HTTPS, as above. The repo is public, so this needs no credential — and the
MacBook's key authorizes inbound SSH to the *installed* system, not outbound access to
GitHub from the ISO. Pushing is dealt with after first boot (step 6).

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
nix --extra-experimental-features 'nix-command flakes' eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
git commit -am "fix: reconcile hardware-configuration.nix with nixos-generate-config"
```

Success is a single store path ending in `.drv`. Nothing is built; this only proves the
configuration evaluates, which is where a typo or a duplicate option definition surfaces
while a disk is still intact.

### 4. Partition — DESTRUCTIVE, ask first

This erases the Samsung. Get a clear go-ahead from Carlos immediately before running it.

First read what it will do. Adding `--dry-run` builds the script and prints **the path to
it**, not its contents, so the audit is a second command:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1 -- --mode destroy,format,mount --flake .#desktop --dry-run
```

```sh
grep -o -e '/dev/[^" )]*' /nix/store/<hash>-disko-destroy-format-mount/bin/disko-destroy-format-mount | sort -u
```

That prints every device path the script can touch, deduplicated. Expect only the Samsung
by-id path, `/dev/disk/by-partlabel/disk-primary-{ESP,luks}` (labels this script creates),
`/dev/mapper/cryptroot`, and `/dev/null`. Anything resolving to the Crucial means stop.

Then the real run:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1 -- --mode destroy,format,mount --flake .#desktop
```

`--mode destroy,format,mount` is the current spelling (the old `--mode disko` is
deprecated). Disko prompts for confirmation and lists the disks it will wipe; there is a
`--yes-wipe-all-disks` flag that skips the dialogue. **Do not pass it.**

It will prompt for the LUKS passphrase interactively. Nothing secret is written to the repo
or the store.

Verify before proceeding:

```sh
lsblk -f
mount | grep /mnt     # expect /mnt, /mnt/home, /mnt/nix, /mnt/boot
```

### 5. Install

```sh
sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake .#desktop
```

The `NIX_CONFIG` prefix is required. The ISO's nix has flakes disabled, and `nixos-install`
invokes nix internally where `--extra-experimental-features` on the outer command does not
reach.

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
- [ ] Log in as `carlos` / `changeme` at the console, then **immediately `passwd`**
- [ ] Network is up (`ping -c1 github.com`)
- [ ] **`ssh carlos@<address>` from the MacBook works** — this is the first real test that
      `authorizedKeys` is right. If it fails you still have the console; if you had *also*
      gotten `passwd` wrong you would have neither.
- [ ] Clone the repo to its permanent home and rebuild **from the installed system** — this
      is the actual done-criterion, not the install:

      git clone -b nixos https://github.com/cadomani/.dotfiles.git ~/.dotfiles
      sudo nixos-rebuild switch --flake ~/.dotfiles#desktop

- [ ] To *push* from the desktop, give it an outbound GitHub credential — either restore the
      backed-up Arch key to `~/.ssh/id_ed25519` (`chmod 600`) and switch the remote to SSH,
      or generate a fresh key here and add it to GitHub, retiring the Arch one. Cloning over
      HTTPS needs neither, which is why the clone above does.

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
