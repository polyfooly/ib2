
.SILENT:

BULMA_VER=0.8.0
export WEBAPP_OUTPUT=dist-ghcjs/build/x86_64-linux/ghcjs-8.4.0.1/frontend-0.1.0.0/x/webapp/build/webapp/webapp.jsexe

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

BULMA=frontend/src/styles/bulma
BULMA_AR=https://github.com/jgthms/bulma/releases/download/$(BULMA_VER)/bulma-$(BULMA_VER).zip
$(BULMA):
	cd frontend/src/styles && \
		wget --no-verbose -O bulma.zip $(BULMA_AR) && \
		unzip -q bulma.zip && \
		mv bulma-$(BULMA_VER) bulma && \
		rm bulma.zip

$(WEBAPP_OUTPUT):
	mkdir -p $(WEBAPP_OUTPUT)
build-css: $(WEBAPP_OUTPUT) $(BULMA)
	sass --no-source-map frontend/src/styles/main.scss:$(WEBAPP_OUTPUT)/main.css
