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
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in
    {
      nixosConfigurations = forAllSystems (system: {
        dhcpServer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nix/roles/dhcpServer.nix
          ];
        };
      });

      # Provide some binary packages for selected system types.
      #packages = forAllSystems (system: {
      #  inherit (nixpkgsFor.${system}) coldsnap messenger;
      #});

      # Like nix-shell
      # Good example: https://github.com/tcdi/pgx/blob/master/flake.nix
      devShell = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          scale_python = with pkgs; python38.withPackages
            (pythonPackages: with pythonPackages; [ pytest pylint ]);
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            scale_python
          ];

          shellHook = ''
          '';
        });
    };
  # Bold green prompt for `nix develop`
  # Had to add extra escape chars to each special char
  nixConfig.bash-prompt = "\\[\\033[01;32m\\][nix-flakes \\W] \$\\[\\033[00m\\] ";

}
