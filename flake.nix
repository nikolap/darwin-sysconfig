{
  description = "Nik's darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    skuld.url = "github:DEEP-IMPACT-AG/skuld/master";
    skuld.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager, skuld, ... }@inputs:
    let
      localName = "nik-macbook";
      system = "aarch64-darwin";

      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs.lib)
        attrValues makeOverridable optionalAttrs singleton;
      nixpkgsConfig = { config = { allowUnfree = true; }; };
    in {
      darwinConfigurations = rec {
        ${localName} = darwinSystem {
          system = system;
          modules = [
            # Main `nix-darwin` config
            ./configuration.nix
            # `home-manager` module
            home-manager.darwinModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              # `home-manager` config
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nperic = import ./home.nix;
              environment.systemPackages = [ (skuld.defaultPackage.${system}) ];
            }
          ];
        };
      };
    };
}
