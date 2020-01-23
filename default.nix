(import ./reflex-platform {}).project ({ pkgs, ... }:
{
  packages = {
    frontend = ./frontend;
    common = ./common;

    node = ./backend/node;
    frontendhost = ./backend/frontendhost;
    posts = ./backend/posts;

    ib2-lib = ./backend/lib;
  };

  withHoogle = false;

  overrides = self: super: (builtins.listToAttrs 
  ( (map (x: { name = x; value = pkgs.haskell.lib.dontCheck super.${x}; }) 
    [ "Glob"
      "wai-extra"
      "wai-app-static"
      "silently"
      "mockery" 
      "unliftio" 
      "yaml"
      "conduit"
      "brittany" 
      "reflex-dom-core"
      "eventstore"
    ]) ++
    (map (x: { name = x; value = pkgs.haskell.lib.dontCheck
      ( pkgs.haskell.lib.overrideCabal super.${x} (drv: 
        { testHaskellDepends = []; })
      ); })
    [ "servant"
      "servant-server"
      "http-date"
      "iproute"
      "unix-time"
      "http2"
      "bsb-http-chunked"
    ]) ++
    (map (x: { name = x; value = pkgs.haskell.lib.dontHaddock 
      ( pkgs.haskell.lib.overrideCabal super.${x} (drv:
        { libraryToolDepends = []; })
      ); })
    [ "frontend"
      "common"
      "node"
      "frontendhost"
      "posts"
      "ib2-lib"
    ])
  )) // {
    servant-reflex = self.callPackage ./packages/servant-reflex.nix {};
    reflex-dom-contrib = self.callPackage ./packages/reflex-dom-contrib.nix {};
  };

  shells = {
    ghc = ["common" "node" "frontendhost" "posts" "ib2-lib"];
    ghcjs = ["common" "frontend"];
  };

  shellToolOverrides = ghc: super: {
    ccjs = pkgs.closurecompiler;

    sass = import ./packages/dart-sass.nix {};
    
    inherit (pkgs.haskellPackages) hpack;
    inherit (pkgs) unzip;
    inherit (pkgs) wget;
  };
})
