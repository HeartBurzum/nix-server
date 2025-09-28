{pkgs, fetchFromGitHub, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "dns-blocklists";
  version = "37512025.271.76637";

  src = fetchFromGitHub {
    owner = "hagezi";
    repo = "dns-blocklists";
    rev = "${version}";
    sha256 = "sha256-mAlSkiqqrgkVFxuK/oV9rfLzqQaTXcu9cZPpmyiuaRE=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
}
