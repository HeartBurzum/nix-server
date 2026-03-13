{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.71.83169";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-ZzMX5TxoMufynwNjXllwfKDxwgYpAj11Lzr9KLpBRJw=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
