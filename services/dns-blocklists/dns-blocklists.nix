{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.155.70723";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-TY1ppeGMoBV3gaJPRtBlIvi9hhJ6u6xdSWGD9/RQitY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
