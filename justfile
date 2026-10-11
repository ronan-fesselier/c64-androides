target := "c64"
cfg    := "src/c64-min.cfg"

build:
    mkdir -p build
    ca65 -v -t {{target}} -l build/charset.lst  -o build/charset.o  src/charset.asm
    ca65 -v -t {{target}} -l build/engine.lst   -o build/engine.o   src/engine.asm
    ca65 -v -t {{target}} -l build/levels.lst   -o build/levels.o   src/levels.asm
    ca65 -v -t {{target}} -l build/map.lst      -o build/map.o      src/map.asm
    ca65 -v -t {{target}} -l build/menu.lst     -o build/menu.o     src/menu.asm
    ca65 -v -t {{target}} -l build/sprites.lst  -o build/sprites.o  src/sprites.asm
    ca65 -v -t {{target}} -l build/text.lst     -o build/text.o     src/text.asm
    ca65 -v -t {{target}} -l build/title.lst    -o build/title.o    src/title.asm

    ld65 -v -C {{cfg}} -m build/androides.map -Ln build/androides.sym -o build/androides.prg build/charset.o build/engine.o build/levels.o build/map.o build/menu.o build/sprites.o build/text.o  build/title.o

run: build
    x64sc -autostartprgmode 1 -autostart build/androides.prg

vice:
    x64sc

clean:
    rm -rf build
