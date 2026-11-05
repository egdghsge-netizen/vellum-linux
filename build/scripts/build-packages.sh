#!/bin/sh
# Build all local Vellum Debian packages without modifying the host.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
OUT="$ROOT/dist"
command -v dpkg-buildpackage >/dev/null 2>&1 || { echo 'Missing dpkg-buildpackage (install devscripts/build-essential).' >&2; exit 1; }
mkdir -p "$OUT"
for package in vellum-defaults vellum-welcome; do
    src="$ROOT/packages/$package"
    [ -f "$src/debian/control" ] || { echo "Missing package source: $src" >&2; exit 1; }
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT HUP INT TERM
    cp -R "$src" "$tmp/$package"
    (cd "$tmp/$package" && dpkg-buildpackage -us -uc -b)
    find "$tmp" -maxdepth 1 -type f -name '*.deb' -exec cp -f {} "$OUT/" \;
    rm -rf "$tmp"
    trap - EXIT HUP INT TERM
done
printf 'Built package artifacts in %s\n' "$OUT"
