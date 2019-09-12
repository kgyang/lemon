
all: boot_sector.bin

boot_sector.bin: boot_sector.asm
	nasm -f bin -o $@ $^

run: boot_sector.bin
	qemu-system-x86_64 -drive format=raw,file=$^

clean:
	rm -f *.o *.bin
