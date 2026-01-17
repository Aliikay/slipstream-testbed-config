This repo contains the nixos configuration for installing a standard test environment for Slipstream.

# Installation
Download a NixOS iso from [the official website](https://nixos.org/download/) and boot into it.
Ignore the graphical installer and instead run this command:
```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake github:Aliikay/slipstream-testbed-config#slipstream-testbed && sudo mkdir /mnt/temp-install && TMPDIR=/mnt/temp-install sudo nixos-install --flake github:Aliikay/slipstream-testbed-config#slipstream-testbed --show-trace --no-write-lock-file && nixos-enter --root /mnt -c 'passwd slipstream-testbed'
```
