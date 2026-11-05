# Vellum Linux

**Vellum Linux 1.0 — Initial Release** is the project to build a Mint-based desktop distribution with its own branding, Cinnamon defaults, first-run experience, and reproducible packaging.

> Status: engineering scaffold / early development. This repository does not yet contain a bootable ISO. No build or VM tests are claimed as passed.

**Built for freedom.**

## Project goals

- Use a legitimate Linux Mint Cinnamon ISO as the base; keep its installer and core system components intact.
- Deliver Vellum branding and safe desktop defaults as installable Debian packages.
- Prefer native Mint/system tools for updates, networking, audio, software installation, and administration.
- Make changes reviewable and repeatable; never silently repartition disks or disable essential services.
- Preserve third-party software licenses and provide attribution for bundled artwork.

## Repository map

- `branding/` — logo assets and visual identity.
- `desktop/` — Cinnamon theme and defaults.
- `applications/vellum-welcome/` — first-run welcome app.
- `packages/` — Debian package sources for Vellum defaults and welcome app.
- `build/` — build helpers and ISO workflow documentation.
- `docs/` — architecture, installation, security, and troubleshooting.
- `tests/` — packaging and static checks; these are not a substitute for boot/installation tests.

## Build the Debian packages

On an Ubuntu 24.04 or compatible Linux Mint build host, install the packaging tools, then run:

```sh
sudo apt install build-essential debhelper devscripts python3
./build/scripts/build-packages.sh
```

The script builds local `.deb` packages under `dist/`. Review package contents before installing. The welcome app uses GTK 3 through the distribution's Python GObject bindings; runtime dependencies are declared by its package.

## ISO status and workflow

The repository currently builds project packages, not a remastered ISO. See [docs/BUILD.md](docs/BUILD.md) for a cautious ISO workflow based on a verified official Mint image and Cubic. Confirm the selected Mint release, edition, architecture, download and checksum against Linux Mint's official site before building. Do not distribute an ISO until it has been built and tested in BIOS/UEFI virtual machines and its checksum has been generated.

## Contributing

Keep changes small, document runtime dependencies and licensing, and report tests actually performed. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/SECURITY.md](docs/SECURITY.md).
