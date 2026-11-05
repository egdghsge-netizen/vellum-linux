# Build guide

## 1. Choose and verify the Mint base

Download the Linux Mint Cinnamon x86_64 ISO from the official Linux Mint download pages. Check the release is still supported and verify the downloaded image against the checksum/signature published by Linux Mint. Keep a record of the exact filename, version, official download URL, and SHA-256. Do not use an unofficial mirror or an unverified image as a release base.

## 2. Build Vellum packages

On a disposable Ubuntu 24.04 / compatible Mint build machine:

```sh
sudo apt update
sudo apt install build-essential debhelper devscripts python3
./build/scripts/build-packages.sh
```

The output is written to `dist/`. Inspect it before use:

```sh
dpkg-deb --info dist/*.deb
dpkg-deb --contents dist/*.deb
```

The build helper does not use sudo and does not modify the host system.

## 3. Customize the ISO

The initial project workflow uses Cubic as an interactive ISO customization environment because the Mint live image includes boot and installer details that should not be reconstructed by a simplistic ISO repack script.

1. Install Cubic from its maintained project instructions on a dedicated build host.
2. Start a project using the verified official Mint ISO; work on a copy.
3. In Cubic's chroot, copy the Vellum `.deb` artifacts into the chroot and install only those packages with `apt install ./package.deb`. Review the package plan and ensure no base component is removed or downgraded.
4. Apply the documented Cinnamon defaults and branding; do not remove Mint installer, live-boot, initramfs, GRUB, or recovery components.
5. Generate the customized image with Cubic and retain its build log and source manifest.

This is a documented interactive workflow, not a fully automated ISO pipeline. Automation and signing are future work. Never use an ISO from this repository as a release until it has been boot-tested.

## 4. Validate before distribution

- Verify the resulting ISO is readable and record its SHA-256 (`sha256sum vellum*.iso`).
- Boot in a disposable VM in UEFI mode and, if supported by the base image, legacy BIOS mode.
- Check live desktop, network, audio, installer launch, installation into a disposable virtual disk, and first boot after installation.
- Verify package installation/removal and that the original Mint updater and installer still function.
- Record failures and exact test environment. Do not report unrun checks as passed.

## Scope

These instructions do not create an ISO automatically and do not authorize overwriting physical disks. Use a disposable VM for installation testing. The installer may erase its selected target disk if the operator chooses that option; review the target and warnings carefully.
