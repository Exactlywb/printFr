#include <stdio.h>

extern "C"  void printFr 	(const char*, ...);
			void Checker 	(int a, int b);

int main () {

	printFr ("Here\n%s\nTEST\n", "IS");
	printFr ("%c %s %d is %b, %o and even %h, and I %s %h %d %% %c%b", 'I', "exactly know that", 3802, 3802, 3802, 3802, "love", 3802, 100, 33, 127);
	printf  ("\n");	//check that next program still works
	printFr ("Hee-h%c%z", 'e', 'e');	//catch error here
	printf  ("\n");	//check that next program still works

	if (true)
		printf ("It's ok here\n");

	printFr ("Test escape commands \t and it still works\n");

	Checker (5, 8);

	return 0;
}

void Checker (int a, int b) {

	printFr ("Here we got %d\n", a + b);

}
