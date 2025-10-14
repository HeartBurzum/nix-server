{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.287.55281";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-9eUXtmlk8LlwQ4xXcz4I+5hnoYel4c2tp2KObVvZe7g=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
