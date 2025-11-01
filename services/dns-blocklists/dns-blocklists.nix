{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.305.9483";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-oJ89memuNQORZJXH8ryYYdW689B62RY+DCIIjLgKYGk=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
