
all: bootsect.bin

bootsect.bin: bootsect.asm
	nasm -f bin -o $@ $^

run: bootsect.bin
	qemu-system-x86_64 -drive format=raw,file=$^

clean:
	rm -f *.o *.bin
