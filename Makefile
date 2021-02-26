-all: printFrolov.out clean
	
printFrolov.out: main.o printFrolov.o
	g++ -no-pie -o printFrolov main.o printFrolov.o

main.o:
	g++ -c main.cpp

printFrolov.o:
	nasm -f elf64 printFrolov.s

clean:
	rm *.o
