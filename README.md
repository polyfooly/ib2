## Imageboard with service-oriented event-driven architecture

### Dependencies

- make
- binutils
- hpack
- EventStore

### Build
Enter the reflex-platform shell, this will install nix, compilers and basic dependencies:

```shell
make enter-shell
```

Update cabal database:

```shell
cabal new-update
```

Configure cabal packages and build everything:

```shell
make
```

##### TODO:
- docker containerization
