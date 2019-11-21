(import ./reflex-platform {}).project ({ pkgs, ... }:
{
  packages = {
    frontend = ./frontend;
    common = ./common;
    node = ./backend/node;
    frontendhost = ./backend/frontendhost;
  };

  overrides = self: super: rec {
    servant-reflex = self.callPackage ./packages/servant-reflex.nix {};
    Glob = pkgs.haskell.lib.dontCheck super.Glob;
    silently = pkgs.haskell.lib.dontCheck super.silently;
    hpack = pkgs.haskell.lib.dontCheck super.hpack;
    mockery = pkgs.haskell.lib.dontCheck super.mockery;
    servant = pkgs.haskell.lib.dontCheck ( pkgs.haskell.lib.overrideCabal super.servant (drv: {
      testHaskellDepends = [];
    }));
    unliftio = pkgs.haskell.lib.dontCheck super.unliftio;
    yaml = pkgs.haskell.lib.dontCheck super.yaml;
    conduit = pkgs.haskell.lib.dontCheck super.conduit;
    brittany = pkgs.haskell.lib.dontCheck super.brittany;
    reflex-dom-core = pkgs.haskell.lib.dontCheck super.reflex-dom-core;

    backend = pkgs.haskell.lib.dontHaddock super.backend;
    common = pkgs.haskell.lib.dontHaddock (pkgs.haskell.lib.overrideCabal super.common (drv: { libraryToolDepends = []; }));
    frontend = pkgs.haskell.lib.dontHaddock (pkgs.haskell.lib.overrideCabal super.frontend (drv: { libraryToolDepends = []; }));
  };

  shells = {
    ghc = ["common" "node" "frontendhost" ];
    ghcjs = ["common" "frontend"];
  };

  shellToolOverrides = ghc: super: {
    ccjs = pkgs.closurecompiler;
  };
})
