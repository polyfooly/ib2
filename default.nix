(import ./reflex-platform {}).project ({ pkgs, ... }:
{
  packages = {
    frontend = ./frontend;
    common = ./common;
    node = ./backend/node;
    frontendhost = ./backend/frontendhost;
    posts = ./backend/posts;
  };

  overrides = self: super: rec {
    servant-reflex = self.callPackage ./packages/servant-reflex.nix {};

    servant = pkgs.haskell.lib.dontCheck ( pkgs.haskell.lib.overrideCabal super.servant (drv: {
      testHaskellDepends = []; # testdoc broken dependency
    }));

    # all these test would fail for some reason during GHCJS build (maybe its bad?)
    # TODO: refactor it
    Glob = pkgs.haskell.lib.dontCheck super.Glob;
    silently = pkgs.haskell.lib.dontCheck super.silently;
    hpack = pkgs.haskell.lib.dontCheck super.hpack;
    mockery = pkgs.haskell.lib.dontCheck super.mockery;
    unliftio = pkgs.haskell.lib.dontCheck super.unliftio;
    yaml = pkgs.haskell.lib.dontCheck super.yaml;
    conduit = pkgs.haskell.lib.dontCheck super.conduit;
    brittany = pkgs.haskell.lib.dontCheck super.brittany;
    reflex-dom-core = pkgs.haskell.lib.dontCheck super.reflex-dom-core;
    eventstore = pkgs.haskell.lib.dontCheck super.eventstore;

    # TODO: maybe optional dontHaddock for jsaddle, servant (due to too long first build)
    backend = pkgs.haskell.lib.dontHaddock super.backend;
    common = pkgs.haskell.lib.dontHaddock (pkgs.haskell.lib.overrideCabal super.common (drv: { libraryToolDepends = []; }));
    frontend = pkgs.haskell.lib.dontHaddock (pkgs.haskell.lib.overrideCabal super.frontend (drv: { libraryToolDepends = []; }));
  };

  shells = {
    ghc = ["common" "node" "frontendhost" "posts" ];
    ghcjs = ["common" "frontend"];
  };

  shellToolOverrides = ghc: super: {
    ccjs = pkgs.closurecompiler;
  };
})
