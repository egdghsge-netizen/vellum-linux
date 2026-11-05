#!/usr/bin/env bash
# Build Vellum Debian packages in temporary source trees; does not install on host.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
OUT="$ROOT/dist"
command -v dpkg-buildpackage >/dev/null 2>&1 || { echo 'Missing dpkg-buildpackage (install build-essential, debhelper, devscripts).' >&2; exit 1; }
mkdir -p "$OUT"
for package in vellum-defaults vellum-welcome; do
    src="$ROOT/packages/$package"
    [[ -f "$src/debian/control" ]] || { echo "Missing package source: $src" >&2; exit 1; }
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT HUP INT TERM
    cp -R "$src" "$tmp/$package"
    # GitHub-created files may not have executable mode bits; Debian requires these.
    chmod +x "$tmp/$package/debian/rules"
    [[ ! -f "$tmp/$package/debian/postinst" ]] || chmod +x "$tmp/$package/debian/postinst"
    (cd "$tmp/$package" && dpkg-buildpackage -us -uc -b)
    find "$tmp" -maxdepth 1 -type f -name '*.deb' -exec cp -f {} "$OUT/" \;
    rm -rf "$tmp"
    trap - EXIT HUP INT TERM
done
printf 'Built package artifacts in %s\n' "$OUT"
