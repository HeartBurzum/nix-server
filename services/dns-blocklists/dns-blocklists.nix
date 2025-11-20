{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.324.24018";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-Ct3xCmV8ITOhnOSwvIFOJ+/35GXcd5afLBpajntN+c8=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
