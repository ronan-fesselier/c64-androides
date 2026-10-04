target := "c64"
cfg    := "src/c64-min.cfg"

build:
    mkdir -p build
    ca65 -v -t {{target}} -l build/engine.lst   -o build/engine.o   src/engine.asm

    ld65 -v -C {{cfg}} -m build/androides.map -Ln build/androides.sym -o build/androides.prg build/engine.o

run: build
    x64sc -autostartprgmode 1 -autostart build/androides.prg

vice:
    x64sc

clean:
    rm -rf build
