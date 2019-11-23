## Imageboard with service-oriented event-driven architecture

### Dependencies:

#### External
- nix
- make
- binutils
- EventStore

### Build
You may want to use cachix repo with binary cache:
```shell
cachix use polyfooly
```

Native part:
```shell
make enter-shell
make configure
make build
```
GHCJS:
```shell
make enter-shell-js
make build-js
```

##### TODO:
- docker containerization
