{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.bhyve;

in {
  options = {
    bhyve = {
      baseImageSize = mkOption {
        type = with types; either (enum [ "auto" ]) int;
        default = "auto";
        example = 2048;
        description = lib.mdDoc ''
          The size of the hyper-v base image in MiB.
        '';
      };
      vmDerivationName = mkOption {
        type = types.str;
        default = "nixos-bhyve-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
        description = lib.mdDoc ''
          The name of the derivation for the hyper-v appliance.
        '';
      };
      vmFileName = mkOption {
        type = types.str;
        default = "nixos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.vhdx";
        description = lib.mdDoc ''
          The file name of the hyper-v appliance.
        '';
      };
    };
  };

  config = {
    #system.build.bhyveImage = import ../../lib/make-disk-image.nix {
    system.build.bhyveImage = import "${pkgs.path}/nixos/lib/make-disk-image.nix" {
      name = cfg.vmDerivationName;
      #postVM = ''
      #  ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=dynamic -O vhdx $diskImage $out/${cfg.vmFileName}
      #  rm $diskImage
      #'';
      format = "raw";
      diskSize = cfg.baseImageSize;
      #partitionTableType = "efi";
      inherit config lib pkgs;
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    boot.growPartition = true;
    
    boot.loader.timeout = 0;

    boot.loader.grub = {
      device = "/dev/vda";
      version = 2;
      #efiSupport = true;
      #efiInstallAsRemovable = true;
    };

    #virtualisation.bhyveGuest.enable = true;
  };
}
