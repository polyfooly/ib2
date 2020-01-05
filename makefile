
export NIX_BUILD_CORES=1
enter-shell:
	nix-shell -A shells.ghc
enter-shell-js:
	nix-shell -A shells.ghcjs

PKGS=frontend common backend/node backend/frontendhost backend/posts backend/lib
HPACK_ARGS=
configure:
	for pkg in $(PKGS); do \
		hpack $$pkg $(HPACK_ARGS); \
	done

configure-force:
	make HPACK_ARGS=--force configure

CABAL_BUILD_OPTIONS=-j1
build:
	cabal new-build all $(CABAL_BUILD_OPTIONS)

build-js:
	cabal new-build --project-file=cabal-ghcjs.project --builddir=dist-ghcjs all $(CABAL_BUILD_OPTIONS)
