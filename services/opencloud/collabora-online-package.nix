{ lib, pkgs, hunspell, hunspellDicts, fetchpatch, ... }:

pkgs.collabora-online.overrideAttrs (old: {
      version = "25.04.1-1";
      src = pkgs.fetchFromGitHub {
        owner = "CollaboraOnline";
        repo = "online";
        tag = "cp-25.04.1-1";
        hash = "sha256-DaMlM/U5oTwsSkdz0AwyzeLnNXMy2lERUdGTm7XKr+0=";
      };

      postInstall = old.postInstall + ''
        ${lib.getExe' pkgs.openssh "ssh-keygen"} -t rsa -N "" -m PEM -f $out/etc/coolwsd/proof_key
      '';
#      patches = [
#        
#      ];
      postPatch = ''
        cp ${./collabora-online-package-lock.json} ${old.npmRoot}/package-lock.json

        patchShebangs browser/util/*.py coolwsd-systemplate-setup scripts/*
        substituteInPlace configure.ac --replace-fail '/usr/bin/env python3' python3
        substituteInPlace coolwsd-systemplate-setup --replace-fail /bin/pwd pwd
      '';
      npmDeps = pkgs.fetchNpmDeps {
        unpackPhase = "true";
        postPatch = ''
          cp ${./collabora-online-package-lock.json} package-lock.json
        '';
        hash = "sha256-MnwKU7mcz/aTCUkHfusF5EgSEvjgaAprouvgfvJQ+mE=";
      };
    })
