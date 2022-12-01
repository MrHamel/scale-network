{ config, lib, pkgs, ... }:
{
  # If not present then warning and will be set to latest release during build
  system.stateVersion = "21.11";

  users.users = {
    rherna = {
      isNormalUser = true;
      uid = 2005;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEiESod7DOT2cmT2QEYjBIrzYqTDnJLld1em3doDROq" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    kea
    expect
  ];

  systemd.services.filegen = {
    path = [ filegen ];
    script = "filegen";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
