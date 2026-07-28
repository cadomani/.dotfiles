# CLAUDE.md

NixOS configuration for `desktop`, a dual-boot workstation. Read this before changing
anything here.

## Read these first, in this order

1. **`DECISIONS.md`** — every non-obvious choice, with what was rejected and why. Append-only.
   Several entries exist specifically to stop a future reader from "cleaning up" something
   load-bearing. Read it before improving anything.
2. **`ROADMAP.md`** — Done / In progress / Backlog. Update it at the end of every stage.
3. **`INSTALL.md`** — how this machine was installed, and the six things that diverged from
   the plan.

## Who you are working with

Carlos is learning NixOS by doing it, and runs every command himself. So:

- Give **one step at a time** and wait for the output before the next one.
- Explain what a command does and **why each option is there**, not just what to type.
- Do not run operational commands on his behalf. Editing config files is welcome.
- Before anything destructive, explain the failure mode and ask for an explicit go-ahead.

Config changes travel by **push and pull**: edit here, commit, push, and he pulls on the
target machine. Do not hand-edit files on a target host.

Write every shell command **on a single line**. Backslash line continuations break when
pasted.

## Working agreement

- **One stage at a time.** Each stage introduces exactly one new failure domain, so that
  when something breaks there is only one candidate. Do not build scaffolding for a later
  stage, however obvious it seems.
- **Smallest diff that advances the current stage.** A change that can be split without
  losing coherence should be split.
- **Verify, do not recall.** Check option names and attributes against the module source or
  upstream docs at the time you write them. This is not theoretical: `enableAutosuggestions`
  and `programs.git.userEmail` are both renamed, and both are still what most guides show.
  Both were caught here, one of them only by an evaluation warning.
- **Only set options that differ from the upstream default.** Restating a default implies a
  decision was made where none was. `enableCompletion` and three `history` options are
  already true upstream, which is why they do not appear in `home/carlos.nix`.
- **Comments explain why, never what.** The code already says what it does.

## Hard invariants

Breaking any of these produces an error that does not point at its own cause.

- **disko owns `fileSystems` and `swapDevices`.** `hosts/desktop/hardware-configuration.nix`
  must never define either. A duplicate definition is an eval failure whose message points
  nowhere near the real problem. When regenerating that file, `--no-filesystems` is
  mandatory.
- **The Windows disk is never named in this repo.** `hosts/desktop/disko.nix` names exactly
  one device, by `/dev/disk/by-id/` model and serial. The Crucial CT2000P5PSSD8 (serial
  `23143FB5191D`) appears nowhere, which is what keeps it outside the blast radius by
  construction rather than by care. Never use `/dev/nvme0n1` or `/dev/nvme1n1` in any
  command: kernel names are probe-order and are not stable across boots. On this machine the
  Samsung is currently `nvme1n1` and Windows is `nvme0n1`, which is the reverse of the
  intuitive guess.
- **`home/` holds no NixOS options.** Those modules are meant to be imported unchanged by a
  nix-darwin host on an M1 mini later, and that stays cheap only if the coupling never
  happens. `home.username` and `home.homeDirectory` stay unset; the NixOS module fills them
  in. Anything NixOS-specific belongs in `hosts/desktop/default.nix`.
- **`system.stateVersion` and `home.stateVersion` are never updated.** They record which
  release's stateful defaults each was built against. They stay where they are forever.
- **Unfree packages are allowed one at a time**, via `nixpkgs.config.allowUnfreePredicate`.
  Do not replace it with `allowUnfree = true`. Its absence is what keeps enabling the NVIDIA
  driver an explicit decision rather than a side effect.
- **zsh needs both halves.** home-manager writes `~/.zshrc` but cannot edit `/etc/passwd`.
  Without `programs.zsh.enable` and `users.users.carlos.shell` on the NixOS side, the login
  shell stays bash and none of the home-manager config is ever sourced.

## Layout

| Path | What it is |
|---|---|
| `flake.nix` | Inputs (nixpkgs `nixos-unstable`, disko, home-manager) and the one `nixosConfiguration`, `desktop` |
| `hosts/desktop/disko.nix` | Declarative disk layout. The only file naming a physical disk |
| `hosts/desktop/hardware-configuration.nix` | Hardware scan results, reconciled against `nixos-generate-config` |
| `hosts/desktop/default.nix` | System config, and the seam where home-manager is wired in |
| `home/carlos.nix` | The whole user environment. No NixOS options |
| `home/claude/global.md` | Written to `~/.claude/CLAUDE.md` by home-manager |

## The machine

| | |
|---|---|
| CPU | Intel i9-13900K (Raptor Lake) |
| RAM | 128 GB |
| GPU | NVIDIA RTX 5090 (GB202, Blackwell) |
| Disks | Samsung 990 PRO 2TB (NixOS), Crucial P5 Plus 2TB (Windows, untouched) |
| Root | LUKS on btrfs, subvolumes `/root` `/home` `/nix`, no swap |
| Boot | systemd-boot, systemd initrd, own ESP. Firmware boots Windows first; the NixOS entry is called "Linux Boot Manager" |

## Commands

Rebuild after any change:

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#desktop
```

Check that the configuration evaluates without building it:

```sh
nix eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
```

After adding a flake input, lock it **as your own user** before rebuilding. If `sudo
nixos-rebuild` creates `flake.lock` first, the file ends up owned by root and later git
operations fail for reasons that look unrelated to Nix:

```sh
nix flake lock
```

Roll back to the previous generation:

```sh
sudo nixos-rebuild switch --rollback --flake ~/.dotfiles#desktop
```

**Nix only sees git-tracked files.** A new file you forget to `git add` is invisible to the
flake, and the error is a missing attribute rather than a missing file.

## Conventions

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): description`, imperative mood, subject under 72 characters. Types: `feat`,
`fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`, `ci`, `build`.

In documentation, comments, and commit messages: **em dashes are forbidden**, as are dashes
used as clause separators. Rewrite the sentence instead. Dashes are fine for hyphenation,
bullet items, command-line flags, numeric ranges, and horizontal rules.
