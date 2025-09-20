{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, disko, sops-nix, ...}:
  let
    system = "x86_64-linux";
  in {
       nixosConfigurations = {
         pastmaster-miniserver = nixpkgs.lib.nixosSystem {
           inherit system;
           modules = [
             sops-nix.nixosModules.sops
             disko.nixosModules.disko
             ./configuration.nix
             ./mini-server.nix
           ];
         };
         pastmaster-media = nixpkgs.lib.nixosSystem {
           inherit system;
           modules = [
             disko.nixosModules.disko
             ./configuration.nix
             ./media-server.nix
           ];
         };
       };
  };
}
