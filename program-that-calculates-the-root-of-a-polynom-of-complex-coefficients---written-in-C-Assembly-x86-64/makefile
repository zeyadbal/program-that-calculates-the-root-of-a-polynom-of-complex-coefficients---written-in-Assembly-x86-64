all: root

root: asm.o

	gcc -Wall -g -o root asm.o

asm.o: asm.s
	nasm -g -f elf64 -w+all -o asm.o asm.s

clean:
	rm -f *.o root
