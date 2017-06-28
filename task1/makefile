
all: task0b

task0b: task0b.o
	ld -g -m elf_i386 task0b.o -o task0b

task0b.o: task0b.s
	nasm -g -w+all  -f elf  task0b.s -o task0b.o -l task0b.lst

.PHONY:
	clean

clean:
	rm ./*.o task0b task0b.lst
