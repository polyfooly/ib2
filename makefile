#export NIXPKGS_ALLOW_BROKEN=1

all: configure build build-js

enter-shell:
	nix-shell reflex-platform/shell.nix

configure:
	#cabal new-update
	hpack frontend
	hpack common
	hpack backend/node
	hpack backend/frontendhost

CABAL_BUILD_OPTIONS=--allow-newer --allow-older -j
build:
	cabal new-build all $(CABAL_BUILD_OPTIONS)

build-js:
	cabal new-build --project-file=cabal-ghcjs.project all $(CABAL_BUILD_OPTIONS)
