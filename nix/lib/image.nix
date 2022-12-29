# nix-build '<nixpkgs/nixos>' -A config.system.build.cloudstackImage --arg configuration "{ imports = [ ./nixos/maintainers/scripts/cloudstack/cloudstack-image.nix ]; }"

{ config, lib, pkgs, ... }:

with lib;

{
  #imports =
  #  [ ../../../modules/virtualisation/cloudstack-config.nix ];

  system.build.bhyveImage = import ../../../lib/make-disk-image.nix {
    inherit lib config pkgs;
    format = "qcow2";
  };

}
