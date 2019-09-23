
all: boot.bin

boot0.o: boot0.asm
	nasm -f bin -o $@ $^

boot1.o: boot1.asm
	nasm -f bin -o $@ $^

boot.bin: boot0.o boot1.o
	cat $^ > $@

run: boot.bin
	qemu-system-x86_64 -drive format=raw,file=$^

clean:
	rm -f *.o *.bin
