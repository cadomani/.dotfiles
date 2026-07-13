# Declarative disk layout for `desktop`.
#
# SAFETY
# ------
# The `device` line below is the only place in this repo that names a physical disk,
# and it is a /dev/disk/by-id/ path. Kernel names (/dev/nvme0n1, /dev/nvme1n1) are
# assigned in probe order and are NOT stable across boots; by-id encodes model+serial
# and cannot drift onto a different disk.
#
# The Windows drive -- Crucial CT2000P5PSSD8, serial 23143FB5191D -- is not referenced
# anywhere in this repository. disko only touches disks it is told about, so the Windows
# disk and its ESP are outside the blast radius by construction, not by care.
{
  disko.devices.disk.primary = {
    type = "disk";

    # Samsung SSD 990 PRO 2TB, serial S7KHNJ0X706305T. Identified and confirmed 2026-07-12.
    # This is the disk that currently holds Arch. It will be destroyed.
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7KHNJ0X706305T";

    content = {
      type = "gpt";

      partitions = {
        # NixOS gets its own ESP, on its own disk. The Windows ESP is never mounted and
        # never appears in fstab, so a Windows update cannot break our bootloader and a
        # NixOS rebuild cannot break Windows'. Choose between them in the firmware menu.
        ESP = {
          # 2G rather than the customary 512M. Each generation copies a kernel + initrd
          # here; a full ESP makes rebuilds fail at the copy step, weeks later, with an
          # error that does not mention the ESP. 2G is free on a 2TB disk.
          # Paired with boot.loader.systemd-boot.configurationLimit in default.nix.
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            # vfat carries no permission bits, so without a umask the ESP is world-readable
            # and systemd-boot warns about it on every rebuild. 0077 = root only.
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot"; # unlocks to /dev/mapper/cryptroot

            # Neither passwordFile nor keyFile is set, so disko's `askPassword` defaults
            # to true: it prompts once, interactively, at format time. No passphrase is
            # ever written to this repo or to the nix store.
            #
            # `initrdUnlock` also defaults to true, which is what generates the
            # boot.initrd.luks.devices."cryptroot" entry that prompts us at boot.

            settings = {
              # Forward TRIM to the SSD through the encryption layer. Without it the drive
              # cannot reclaim freed blocks and write performance degrades over time. The
              # tradeoff is a confidentiality leak of *which* blocks are unused (not their
              # contents) -- the standard, accepted bargain for an NVMe root.
              allowDiscards = true;
            };

            content = {
              type = "btrfs";

              # Label only, so `lsblk -f` says something meaningful in a rescue shell.
              extraArgs = [ "-L" "nixos" ];

              # Three subvolumes, no more. A subvolume is not a partition: adding one later
              # is `btrfs subvolume create` plus a config line, with no repartitioning and
              # no reinstall. So there is no cost to starting minimal, and adding /var/log
              # or an impermanence @persist volume speculatively now would be adding things
              # nothing yet uses.
              #
              # compress=zstd: transparent compression. On NVMe this is a straight win --
              #   the CPU is faster than the disk, so compressed I/O is *quicker*, not just
              #   smaller, and the nix store compresses extremely well.
              # noatime: do not write an access timestamp on every read. Pure write
              #   amplification otherwise; nothing here consumes atime.
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                # Separate from /, so that snapshotting or rolling back the root subvolume
                # does not drag the (large, and entirely reproducible) store along with it.
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };

  # No swap, deliberately.
  #
  # This machine has 128 GB of RAM, and we are explicitly not doing hibernation (which on
  # LUKS+btrfs needs a resume_offset computed from `btrfs inspect-internal map-swapfile`,
  # and is fragile). Suspend-to-RAM needs no swap at all. A swap device we never page into
  # is a partition we have to reason about forever for no benefit.
  #
  # If memory pressure ever becomes real, zram (compressed swap in RAM, no disk layout
  # change) is the answer, and it can be enabled later with one option. See ROADMAP.md.
}
