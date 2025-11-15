{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.319.24291";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-tGxmdd9oK4E99RggvzzgvlJYFB6gDvxAXsOY9XYM18I=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
