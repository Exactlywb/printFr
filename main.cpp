extern "C" void printFr (const char*, ...);
#include <stdio.h>

int main ()
{
	
	printFr ("%c %s %d is %b, %o and even %x", 'I', "exactly know that", 3802, 3802, 3802, 3802);
	printf  ("\n");	//check that next program still works
	printFr ("Hee-h%c%c", 'e', 'e');
	printf  ("\n");	//check that next program still works

	if (true)
		printf ("It's ok here\n");

	return 0;
}

//DO nasm -f elf64 printik.s -o printik.o