{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.41.39595";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-ATKPvoHLLwxgfmKtnxNltok0R3L0vbNhrS8tci1U9AM=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
