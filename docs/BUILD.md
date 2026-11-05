# Building a bootable Vellum ISO

The build script performs a real live-image remaster: it checks the supplied base ISO hash, extracts the image, unpacks its live root filesystem, installs Vellum `.deb` packages inside that filesystem using the base image's configured APT repositories, rebuilds `filesystem.squashfs`, replaces it in the original ISO while asking xorriso to replay the original boot configuration, and writes a SHA-256 sidecar.

## Important limitations

- This repository does **not** contain a generated ISO. The script must be run on a compatible Linux build machine with sufficient free disk space (allow at least 3x the base ISO size).
- It requires root for temporary bind mounts and chroot, network access inside the chroot for APT, and packages compatible with the exact Mint base.
- It preserves the base ISO's boot files and installer; it does not independently create an installer or guarantee every firmware/VM combination works.
- The script does not repartition disks. ISO installation still uses the upstream Mint installer and its normal confirmation dialogs.
- This is an early development pipeline, not a release process. Boot, live-session, install, and first-boot checks are still required before public distribution.

## Host prerequisites

On an Ubuntu 24.04 / compatible Mint x86_64 build host, install the tools from distribution repositories:

```sh
sudo apt update
sudo apt install build-essential debhelper devscripts xorriso squashfs-tools coreutils findutils
```

Have a verified official Linux Mint Cinnamon x86_64 ISO available and retrieve its expected SHA-256 from the official Mint download verification page. Do not substitute a checksum copied from an untrusted source.

## Build packages and remaster

From the repository root:

```sh
./build/scripts/build-packages.sh
sudo ./build/scripts/remaster-mint-iso.sh \
  /path/to/linuxmint-cinnamon.iso OFFICIAL_BASE_SHA256 \
  /path/to/output/vellum-linux-1.0-amd64.iso \
  "$PWD/dist"
```

The ISO script refuses to overwrite an existing output and aborts if the base checksum differs. It cleans its temporary working directory on exit. Review the script before running it and use a disposable build host; package installation in the chroot uses the network and the base image's configured repositories.

## After generation

The script prints the output hash and writes `vellum-linux-1.0-amd64.iso.sha256`. Verify it and then test the image in a disposable VM before installing on physical hardware. At minimum check UEFI boot, live desktop, network, installer launch, installation to a disposable virtual disk, and installed first boot. Do not call the image tested or release-ready until those checks have actually been performed.
