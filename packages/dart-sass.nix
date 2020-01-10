args@{ pkgs ? import <nixpkgs> {}, ... }:

let src = pkgs.fetchFromGitHub {
    owner  = "polyfooly";
    repo   = "nix-dart-sass";
    rev = "64aae3b25068a4febe881272994899c5cd7d4c69";
    sha256 = "1148bdq6cjrra76nx1k92vb6z3fjczfp1c2ayixn68w55k9rpxjb";
}; 
in import "${src}/default.nix" args
