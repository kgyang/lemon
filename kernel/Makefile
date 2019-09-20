all: kernel.bin

boot.o : boot.S
	gcc -ffreestanding -I. -c -Xassembler --32 -o $@ $^

kernel.o : kernel.c
	gcc -ffreestanding -m32 -I. -c -o $@ $^

kernel.bin: boot.o kernel.o
	gcc -nostartfiles -nostdlib -nodefaultlibs -m32 -o $@ $^

run: kernel.bin
	qemu-system-i386 -kernel $^

clean:
	rm -f *.o *.bin
