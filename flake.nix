{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
    in
    {
      overlays.default = (final: prev:
        with final.pkgs;
        rec {
          scaleTests = import ./nix/tests/allTests.nix { inherit nixosTest; };
        });

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) scaleTests;
      });

      nixosConfigurations = forAllSystems (system:
        let
          # All scale common modules
          common =
            ({ modulesPath, ... }: {
              imports = [
                "${toString modulesPath}/virtualisation/qemu-vm.nix"
              ];
            });
        in
        {
          loghost = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              common
              ./nix/machines/loghost.nix
              ./nix/lib/image.nix
            ];
          };
        });

      # Like nix-shell
      # Good example: https://github.com/tcdi/pgx/blob/master/flake.nix
      devShells = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            default = import ./shell.nix { inherit pkgs; };
          });
    };

  # Bold green prompt for `nix develop`
  # Had to add extra escape chars to each special char
  nixConfig.bash-prompt = "\\[\\033[01;32m\\][nix-flakes \\W] \$\\[\\033[00m\\] ";
}
