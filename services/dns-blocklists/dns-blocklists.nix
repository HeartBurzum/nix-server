{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.286.43245";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-2KhPOZ19ALWI5IzigtjrKtr8gAX/4jPf4wUoD1X9HP0=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
