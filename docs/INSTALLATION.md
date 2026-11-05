# Installation and use

## Current development state

There is no Vellum ISO release yet. Do not install this project on a production computer as if it were a finished distribution.

## Developer package testing

Build packages as described in `docs/BUILD.md`. Review their contents before installation. For isolated tests, use a disposable Mint VM and install a package with `sudo apt install ./package.deb`; remove it afterward with APT. Do not use a physical computer for unreviewed development packages.

## Future ISO installation

When a tested ISO is published, boot it from USB or a VM and use the Linux Mint installer. Follow its language, keyboard, timezone, account, and partitioning prompts. Carefully check the selected disk before confirming any partitioning or formatting operation. Back up important data first.
