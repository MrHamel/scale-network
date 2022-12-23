{ nixosTest }:

nixosTest ({
  #rob = nixosTest ({
  name = "envfs";
  nodes.machine = ../roles/rsyslog.nix;
  #nodes.machine = { ... }: { imports = ./nix/roles/rsyslog.nix; };
  nodes.rob = {
    virtualisation.graphics = false;
  };

  testScript = ''
    start_all()
    machine.succeed("sleep 2")
    machine.succeed("systemctl is-active syslog")
    machine.succeed("logger -n 127.0.0.1 -P 514 --tcp 'troy'")
    machine.succeed("cat /var/log/**/**/root.log | grep troy")
  '';
})
