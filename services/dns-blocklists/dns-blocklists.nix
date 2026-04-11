{ pkgs, fetchFromGitHub, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37522026.100.57445";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-FMQ5vaH++FQq+nw+VOtrXvkQygyKfZCALT4ZcQwzZoc=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
