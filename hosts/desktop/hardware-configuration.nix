# Hardware scan results for `desktop`.
#
# This file is normally machine-generated. It could not be generated when it was written,
# because `nixos-generate-config` does not exist on the Arch install we authored it from,
# so every line is hand-written and justified rather than emitted by a probe.
#
# RECONCILED 2026-07-27 against the real generator on the installer ISO. It found exactly
# one hardware fact this file lacked, `vmd`, which is now present. To repeat the check:
#
#     nixos-generate-config --no-filesystems --dir /tmp/gen
#     diff /tmp/gen/hardware-configuration.nix hosts/desktop/hardware-configuration.nix
#
# `--no-filesystems` is not optional. disko already defines `fileSystems` and
# `swapDevices`; if the generator emits them too you get a duplicate-definition eval
# failure whose message does not point anywhere near the actual cause.
#
# Accordingly: this file must never contain fileSystems or swapDevices. disko owns those.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  # Enables hardware.enableRedistributableFirmware, which ships the vendor firmware blobs
  # that many ethernet and wireless controllers need in order to come up at all. Stage 0's
  # success criteria include "network works", so this is load-bearing, not incidental.
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Modules the initrd may need *before* a root filesystem exists.
  #
  #   vmd                     Intel Volume Management Device. When VMD is on in firmware,
  #                           the NVMe drives sit behind that controller rather than on the
  #                           PCIe bus directly, so `nvme` alone finds nothing. Reported by
  #                           nixos-generate-config on the installer ISO; the hand-written
  #                           list had missed it. Without it the initrd cannot see the root
  #                           disk and drops to an emergency shell citing a missing device.
  #   nvme                    the root disk is NVMe. Without this, initrd cannot see the
  #                           root device at all and the boot dead-ends.
  #   xhci_pci, usbhid        USB host controller and USB HID. These are what let us TYPE
  #                           THE LUKS PASSPHRASE on a USB keyboard. Omitting them yields
  #                           a passphrase prompt that ignores every key you press.
  #   ahci, sd_mod, usb_storage
  #                           SATA and USB mass storage. Not needed for this boot path, but
  #                           they are what make a USB rescue stick usable from this initrd.
  boot.initrd.availableKernelModules = [
    "vmd"
    "nvme"
    "xhci_pci"
    "usbhid"
    "ahci"
    "sd_mod"
    "usb_storage"
  ];

  boot.initrd.kernelModules = [ ];

  # Intel i9-13900K. KVM support for the Intel virtualisation extensions.
  boot.kernelModules = [ "kvm-intel" ];

  boot.extraModulePackages = [ ];

  # Intel CPU microcode. Raptor Lake in particular ships fixes for the elevated-voltage
  # instability that degrades these chips, so this is worth more than the usual "errata"
  # hand-wave. Gated on redistributable firmware being permitted, which the import above
  # turns on.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
