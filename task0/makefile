
all: task0

task0: task0.o
	gcc -g -Wall -m32 task0.o -o task0

task0.o: task0.c
	gcc -g -Wall -m32 -c task0.c -o task0.o

.PHONY:
	clean

clean:
	rm -f ./*.o task0