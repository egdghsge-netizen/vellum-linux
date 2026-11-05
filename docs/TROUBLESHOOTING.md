# Troubleshooting

## Package build reports missing tools

Install the build dependencies listed in `docs/BUILD.md` on a supported Debian/Ubuntu-family build host.

## Welcome application cannot start

The application needs Python 3, GTK 3, and PyGObject (`python3-gi`, `gir1.2-gtk-3.0`). Install the dependencies from the distribution repositories. Run it from a terminal to see diagnostic messages.

## Cinnamon defaults do not apply

Defaults are only seeded for a new user session and do not forcibly replace existing user preferences. Log out and back in, then inspect Cinnamon's theme settings. Existing users can select the Vellum theme manually.

## ISO boot or installer problem

Stop distribution of the image. Compare the build source and logs with the release manifest, rebuild from a verified official base, and reproduce in a disposable VM. Do not attempt to repair a bootloader by deleting Mint packages blindly.
