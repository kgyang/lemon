
all: kernel.bin

bool.o : boot.S
	as --x32 -I ./ -o $@ $^

kernel.o : kernel.c
	gcc -o $@ -c $^

kernel.bin: boot.o kernel.o
	ld -o $@ $^

run: kernel.bin
	qemu-system-x86_64 -kernel $^

clean:
	rm -f *.o *.bin
