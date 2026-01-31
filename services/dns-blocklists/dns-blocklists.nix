{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.31.39159";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-JrvwEPN7j91pHVSMF6VOkAhgRoBEiOQsLjZlrPuPe64=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
