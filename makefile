export NIXPKGS_ALLOW_BROKEN=1

enter-shell:
	nix-shell reflex-platform/shell.nix

BUILD_OPTIONS=--allow-newer --allow-older
ghc-build:
	cabal new-build all -j $(BUILD_OPTIONS)

ghcjs-build:
	cabal new-build --project-file=cabal-ghcjs.project all -j $(BUILD_OPTIONS)
