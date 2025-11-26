{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.330.52951";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-O0rx2zRAlqTvpectwLnUQ+DDsnNiZUXchZwkZUXm5pw=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
