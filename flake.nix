{
  description = "Test";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    devshell-files = {
      url = "github:SnO2WMaN/devshell-files/output-modules";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.devshell.follows = "devshell";
    };
    rust-tools = {
      url = "path:./flakes/rust-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, devshell, flake-utils, devshell-files, rust-tools, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              devshell.overlay
              rust-tools.overlay
            ];
          };
        in
        pkgs.devshell.mkShell {
          imports = [
            (devshell-files.devshellModules)
          ];
          devshell.name = "Overdose";
          devshell.packages = with pkgs;[
            treefmt
            nixpkgs-fmt
            taplo-cli
          ];

          files.direnv.enable = true;
          files.gitignore = {
            enable = true;
            pattern = {
              "**/.direnv" = true;
              ".vscode/settings.json" = true;
              "treefmt.toml" = true;
            };
          };

          files.json.".vscode/settings.json" =
            let langs = [ "toml" "json" "jsonc" "nix" ]; in
            {
              "customLocalFormatters.formatters" = [
                { "command" = "${pkgs.treefmt}/bin/treefmt -q --stdin \${file}"; "languages" = langs; }
              ];
            } //
            builtins.listToAttrs (
              builtins.map
                (lang: {
                  name = "[${lang}]";
                  value = { "editor.defaultFormatter" = "jkillian.custom-local-formatters"; };
                })
                langs
            );

          files.toml."treefmt.toml" = {
            formatter = {
              toml = {
                command = "${pkgs.taplo-cli}/bin/taplo";
                includes = [ "*.toml" ];
              };
              nix = {
                command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
                includes = [ "*.nix" ];
              };
            };
          };

        };
    });
}
