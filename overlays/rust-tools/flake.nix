{
  description = "Rust tools overlay";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs =
    { self, nixpkgs, ... }@inputs: {
      overlay = (self: super: {

        taplo-cli = super.taplo-cli.overrideAttrs (old: rec {
          inherit (old) pname;
          version = "0.6.2";
          src = super.fetchCrate {
            inherit pname;
            inherit version;
            sha256 = "sha256-vz3ClC2PI0ti+cItuVdJgP8KLmR2C+uGUzl3DfVuTrY=";
          };
          cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
            inherit src;
            name = "${old.pname}-${version}-vendor.tar.gz";
            outputHash = "sha256-m6wsca/muGPs58myQH7ZLPPM+eGP+GL2sC5suu+vWU0=";
          });
        });

        treefmt = super.treefmt.overrideAttrs (old: rec {
          inherit (old) pname;
          version = "0.4.1";
          src = super.fetchFromGitHub {
            owner = "numtide";
            repo = "treefmt";
            rev = "v${version}";
            sha256 = "sha256-+EcqrmjZR8pkBiIXpdJ/KfmTm719lgz7oC9tH7OhJKY=";
          };
          cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
            inherit src;
            name = "${pname}-${version}-vendor.tar.gz";
            outputHash = "sha256-DXsKUeSmNUIKPsvrLxkg+Kp78rEfjmJQYf2pj1LWW38=";
          });
        });

      });
    };
}
