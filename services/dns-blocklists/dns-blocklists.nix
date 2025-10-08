{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.280.85840";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-4HYJ8zsmHHF/EfWCfKyGYKO6yjpIURCYnlj5eF+X6gk=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
