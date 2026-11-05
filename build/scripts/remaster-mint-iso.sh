#!/usr/bin/env bash
# Remaster a verified Linux Mint ISO by replacing only its live filesystem.
# Run on a disposable Linux build host. Requires root for chroot/mount operations.
set -Eeuo pipefail

usage() {
  echo "Usage: sudo $0 /path/to/official-mint.iso OFFICIAL_SHA256 /path/to/output.iso /path/to/vellum-packages-dir" >&2
  echo "The package directory must contain the Vellum .deb files produced by build-packages.sh." >&2
  exit 2
}
[[ $# -eq 4 ]] || usage
BASE=$(readlink -f -- "$1")
EXPECTED=${2,,}
OUTPUT=$(readlink -m -- "$3")
PACKAGES=$(readlink -f -- "$4")
[[ $EUID -eq 0 ]] || { echo 'Run this script with sudo; it uses temporary mounts and chroot.' >&2; exit 1; }
[[ -f "$BASE" && -r "$BASE" ]] || { echo "Base ISO not readable: $BASE" >&2; exit 1; }
[[ $EXPECTED =~ ^[0-9a-f]{64}$ ]] || { echo 'Expected SHA-256 must be 64 hexadecimal characters.' >&2; exit 1; }
[[ ! -e "$OUTPUT" ]] || { echo "Refusing to overwrite existing output: $OUTPUT" >&2; exit 1; }
[[ -d "$PACKAGES" ]] || { echo "Package directory not found: $PACKAGES" >&2; exit 1; }
mapfile -t DEBS < <(find "$PACKAGES" -maxdepth 1 -type f -name 'vellum-*.deb' -print | sort)
((${#DEBS[@]} > 0)) || { echo "No vellum-*.deb packages found in $PACKAGES" >&2; exit 1; }

for tool in xorriso unsquashfs mksquashfs mount umount chroot sha256sum find sort; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing required tool: $tool" >&2; exit 1; }
done
printf '%s  %s\n' "$EXPECTED" "$BASE" | sha256sum --check --status || { echo 'Base ISO SHA-256 mismatch; aborting.' >&2; exit 1; }

WORK=$(mktemp -d "${TMPDIR:-/var/tmp}/vellum-iso.XXXXXXXX")
TREE="$WORK/iso"
ROOTFS="$WORK/rootfs"
mkdir -p "$TREE" "$ROOTFS"
MOUNTS=()
cleanup() {
  set +e
  for mountpoint in "${MOUNTS[@]}"; do umount -lf "$mountpoint"; done
  rm -rf -- "$WORK"
}
trap cleanup EXIT HUP INT TERM

# Extract the original ISO with xorriso, preserving its boot image and installer files.
xorriso -osirrox on -indev "$BASE" -extract / "$TREE" >/dev/null
SQUASH="$TREE/casper/filesystem.squashfs"
[[ -f "$SQUASH" ]] || { echo 'This ISO has no casper/filesystem.squashfs; unsupported base image.' >&2; exit 1; }
unsquashfs -f -d "$ROOTFS" "$SQUASH" >/dev/null

# Copy only the requested project packages into the temporary live filesystem.
mkdir -p "$ROOTFS/tmp/vellum-packages"
for deb in "${DEBS[@]}"; do install -m 0644 "$deb" "$ROOTFS/tmp/vellum-packages/"; done

# Bind runtime filesystems only inside the disposable chroot, then install packages
# from the official Mint/Ubuntu repositories configured by the base image.
for dir in dev proc sys; do
  mkdir -p "$ROOTFS/$dir"
  mount --bind "/$dir" "$ROOTFS/$dir"
  MOUNTS+=("$ROOTFS/$dir")
done
chroot "$ROOTFS" /usr/bin/env DEBIAN_FRONTEND=noninteractive /bin/bash -euc '
  apt-get update
  apt-get install -y --no-install-recommends /tmp/vellum-packages/vellum-*.deb
  apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/vellum-packages
'
for mountpoint in "${MOUNTS[@]}"; do umount "$mountpoint"; done
MOUNTS=()

# Rebuild the live root and update the metadata used by the installer/live system.
rm -f "$SQUASH"
mksquashfs "$ROOTFS" "$SQUASH" -noappend -comp xz -b 1M >/dev/null
if [[ -f "$TREE/casper/filesystem.size" ]]; then
  du -sx --block-size=1 "$ROOTFS" | cut -f1 > "$TREE/casper/filesystem.size"
fi
if [[ -f "$TREE/md5sum.txt" ]]; then
  (cd "$TREE" && find . -type f ! -name md5sum.txt -print0 | sort -z | xargs -0 -r md5sum) > "$TREE/md5sum.txt"
fi

mkdir -p "$(dirname -- "$OUTPUT")"
# Updating the original ISO in xorriso keeps its hybrid/UEFI boot configuration
# instead of reconstructing boot records by hand.
xorriso -indev "$BASE" -outdev "$OUTPUT" -overwrite on \
  -boot_image any replay \
  -map "$SQUASH" /casper/filesystem.squashfs \
  $( [[ -f "$TREE/casper/filesystem.size" ]] && printf '%s' "-map $TREE/casper/filesystem.size /casper/filesystem.size" ) \
  $( [[ -f "$TREE/md5sum.txt" ]] && printf '%s' "-map $TREE/md5sum.txt /md5sum.txt" ) \
  -commit >/dev/null

sha256sum "$OUTPUT" | tee "$OUTPUT.sha256"
printf '\nImage created, but not boot-tested: %s\n' "$OUTPUT"
