{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.10.82126";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-bW3MewU3M+O1E4XYJuIYij5gZefcRdQnMba5Tw0WfiU=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
