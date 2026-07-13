# Hardware scan results for `desktop`.
#
# PROVISIONAL -- this file is normally machine-generated, and we could not generate it:
# `nixos-generate-config` does not exist on the Arch install we authored this from. Every
# line below is therefore hand-written and justified, and it must be checked against the
# real generator on the installer ISO before we commit to it:
#
#     nixos-generate-config --no-filesystems --root /mnt --dir /tmp/gen
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
  #   nvme                    the root disk is NVMe. Without this, initrd cannot see the
  #                           root device at all and the boot dead-ends.
  #   xhci_pci, usbhid        USB host controller and USB HID. These are what let us TYPE
  #                           THE LUKS PASSPHRASE on a USB keyboard. Omitting them yields
  #                           a passphrase prompt that ignores every key you press.
  #   ahci, sd_mod, usb_storage
  #                           SATA and USB mass storage. Not needed for this boot path, but
  #                           they are what make a USB rescue stick usable from this initrd.
  boot.initrd.availableKernelModules = [
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
