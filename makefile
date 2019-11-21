#export NIXPKGS_ALLOW_BROKEN=1

#all: configure build build-js

enter-shell:
	nix-shell -A shells.ghc
enter-shell-js:
	nix-shell -A shells.ghcjs

#setup-shell:
#	reflex-platform/try-reflex

configure:
	hpack frontend
	hpack common
	hpack backend/node
	hpack backend/frontendhost

#CABAL_BUILD_OPTIONS=--allow-newer --allow-older -j
CABAL_BUILD_OPTIONS=
build:
	cabal new-build all $(CABAL_BUILD_OPTIONS)

build-js:
	cabal new-build --project-file=cabal-ghcjs.project --builddir=dist-ghcjs all $(CABAL_BUILD_OPTIONS)
