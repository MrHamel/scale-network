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
      #nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ ]; });
    in
    {

      overlay = final: prev:
        with final.pkgs;
        rec {
          scaleTemplates = callPackage ./nix/pkgs/scaleTemplates.nix { };
        };

      nixosConfigurations = forAllSystems (system: {
        dhcpServer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ modulesPath, ... }: {
              imports = [
                "${toString modulesPath}/virtualisation/qemu-vm.nix"
              ];
            })
            ./nix/roles/dhcp/default.nix
          ];
          specialArgs = { pkgs = (nixpkgsFor.${system}); };
        };
        rsyslogServer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ modulesPath, ... }: {
              imports = [
                "${toString modulesPath}/virtualisation/qemu-vm.nix"
              ];
            })
            ./nix/roles/rsyslog.nix
          ];
        };
      });

      # Provide some binary packages for selected system types.
      #packages = forAllSystems (system: {
      #  inherit (nixpkgsFor.${system}) gomplateTemplateFile;
      #});

      # Like nix-shell
      # Good example: https://github.com/tcdi/pgx/blob/master/flake.nix
      devShell = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          # python3.10 inventory.py  | gomplate -d inventory=stdin:///in.json -i '{{ range (ds "inventory").routers }}{{.}}, {{end}}'
          testTemplate = pkgs.writeTextFile {
            name = "inventoryTemplate";
            text = ''
            {{ range (ds "top").routers }}{{.}}, {{end}}
            '';
          };
          gtest = pkgs.scaleTemplates.gomplateFile "gtest" testTemplate ./inventory.json;
          #gtest = pkgs.scaleTemplates.gomplateFile "gtest" testTemplate (builtins.readFile ./inventory.json);
          scale_python = with pkgs; python310.withPackages
            (pythonPackages: with pythonPackages; [ pytest pylint ]);
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            scale_python
            gomplate
          ];

          shellHook = ''
            cat ${gtest.out}
          '';
        });
    };
  # Bold green prompt for `nix develop`
  # Had to add extra escape chars to each special char
  nixConfig.bash-prompt = "\\[\\033[01;32m\\][nix-flakes \\W] \$\\[\\033[00m\\] ";

}
