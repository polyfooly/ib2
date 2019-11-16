{ reflex-platform ? import ./reflex-platform {} }:
reflex-platform.project ({ pkgs, ... }: {
  packages = {
    frontend = ./frontend;
    common = ./common;
    node = ./backend/node;
  };

  shells = {
    ghcjs = [ "frontend" "common" ];
    ghc = [ "common" "node" ];
  };
})
