
all: virus

virus: virus.o
	ld -g -m elf_i386 virus.o -o virus

virus.o: virus.s
	nasm -g -w+all  -f elf  virus.s -o virus.o -l virus.lst

.PHONY:
	clean

clean:
	rm ./*.o virus virus.lst
