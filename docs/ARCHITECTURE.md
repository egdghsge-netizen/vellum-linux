# Architecture

## Baseline

Vellum is a derivative customization of Linux Mint Cinnamon for x86_64, not a new kernel or independent package archive. The initial compatibility target is the Linux Mint 22.x family, based on Ubuntu 24.04 LTS. Select a specific supported point release and official Cinnamon ISO at build time; record its release, URL, and verified SHA-256 in the release manifest. Do not mix packages from unrelated Ubuntu or Debian releases.

Re-check the current Mint support status before a public release. The Mint team controls the base lifecycle and update channels; Vellum does not extend upstream support.

## Keep upstream components

Retain the base kernel, Cinnamon, LightDM, APT, systemd, NetworkManager, GRUB, Plymouth, and the original installer unless a documented compatibility reason requires otherwise. Do not replace Mint's update manager with a Vellum updater in the initial release. Vellum settings should launch the appropriate system settings panel rather than duplicating privileged configuration.

## Layering

1. **Branding assets** — SVG logo and authored artwork, separately licensed/documented.
2. **Desktop defaults package** — installs Vellum GTK/Cinnamon theme assets and system-wide defaults without overwriting user files.
3. **Welcome application** — unprivileged first-run utility that opens existing settings tools and documentation.
4. **ISO customization** — performed against a verified official image in a disposable build environment; install the built packages into the live filesystem and retain installer behavior.

## Privilege boundary

Desktop apps run as the logged-in user. They must not call `sudo`, edit system files directly, or perform package operations with elevated privileges. Use upstream graphical tools and PolicyKit-mediated system interfaces where needed. Destructive disk operations remain the installer's responsibility with its normal confirmations.

## Release requirements

A release needs a pinned base ISO and checksum, package build logs, license/attribution review, successful package installation/removal, live boot and installation tests in UEFI and BIOS where supported, and a published ISO SHA-256. None of these release claims should be inferred from a successful source commit.
