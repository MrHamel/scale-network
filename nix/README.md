# Nix and NixOS configuration

## Local VMs

To build and run the `rsyslogServer` from a NixOS machine:

```
nix build ".#nixosConfigurations.x86_64-linux.rsyslogServer.config.system.build.vm"
./result/bin/run-nixos-vm
```
