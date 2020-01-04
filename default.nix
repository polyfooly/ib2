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
      "hpack"
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
    (map (x: { name = x; value = pkgs.haskell.lib.dontHaddock super.${x}; })
    [ "frontend"
      "common"
      "node"
      "frontendhost"
      "posts"
      "ib2-lib"
    ])
  )) // {
    servant-reflex = self.callPackage ./packages/servant-reflex.nix {};
  };

  shells = {
    ghc = ["common" "node" "frontendhost" "posts" "ib2-lib"];
    ghcjs = ["common" "frontend"];
  };

  shellToolOverrides = ghc: super: {
    ccjs = pkgs.closurecompiler;
  };
})
