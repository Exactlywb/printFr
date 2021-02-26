extern "C" void printFr (const char*, ...);
 
#include <stdio.h>

int main ()
{
	printFr ("%c love that %d is %x", 'I', 3802, 3802);
	printf  ("\n");

	return 0;
}

//DO nasm -f elf64 printik.s -o printik.o