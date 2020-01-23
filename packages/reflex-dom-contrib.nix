{ mkDerivation, stdenv
, aeson
, base64-bytestring
, bifunctors
, bimap
, bytestring
, containers
, data-default
, exception-transformers
, exceptions
, ghc
, ghcjs-dom
, http-types
, jsaddle
, lens
, mtl
, random
, readable
, ref-tf
, reflex
, reflex-dom
, safe
, stm
, string-conv
, text
, time
, transformers
, uri-bytestring
, webkitgtk3-javascriptcore
}:

mkDerivation {
  pname = "reflex-dom-contrib";
  version = "0.6";

  src = builtins.fetchGit {
      url = "https://github.com/reflex-frp/reflex-dom-contrib.git";
      ref = "master";
      rev = "228d283166d2bd8f2dff41635f7101cd7fca3223";
  };

  buildDepends = [
    aeson
    base64-bytestring
    bifunctors
    bimap
    bytestring
    containers
    data-default
    exception-transformers
    exceptions
    ghcjs-dom
    http-types
    jsaddle
    lens
    mtl
    random
    readable
    ref-tf
    reflex
    reflex-dom
    safe
    string-conv
    text
    time
    transformers
    uri-bytestring
  ];

  license = stdenv.lib.licenses.bsd3;
}