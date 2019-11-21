## Imageboard with service-oriented event-driven architecture

### Dependencies

- nix
- make
- binutils (?)
- EventStore

### Build
Enter nix shell (all dependencies will be installed) and build project

Native:
```shell
make enter-shell
make build
```
GHCJS:
```shell
make enter-shell-js
make build-js
```

##### TODO:
- docker containerization
