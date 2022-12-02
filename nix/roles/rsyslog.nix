{ config, lib, pkgs, ... }:
{
  # If not present then warning and will be set to latest release during build
  system.stateVersion = "22.11";

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
    rsyslog
  ];

  services.rsyslog = {
    enable = true;
    defaultConfig = ''
      module(load="imtcp")
      input(type="imtcp" port="514")

      $template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
      *.* ?RemoteLogs
      & ~
    '';
  };
}
