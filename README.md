# c64-androides

Native 6502 port of *Androïdes* (William Hennebois, Infogrames, Thomson TO7, 1985, 6809) to the Commodore 64.

## Prerequisites

| Tool                                       | Purpose                                     |
| ------------------------------------------ | ------------------------------------------- |
| [`cc65`](https://cc65.github.io/)          | 6502 assembler (`ca65`) and linker (`ld65`) |
| [`VICE`](https://vice-emu.sourceforge.io/) | C64 emulator (`x64sc`)                      |
| [`just`](https://github.com/casey/just)    | Command runner used to build/run programs   |

On Debian:

```sh
sudo apt install cc65 vice just
```

## Build

```
just build   # assemble -> build/androides.prg
just run     # build + launch in VICE
just clean   # remove build/
```
