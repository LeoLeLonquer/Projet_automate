#include "tab_symb.h"

int main (void) {  

	Symb a = {'a' , 1, 1, "int", 0} ; 
	Symb b = {'b' , 2, 1, "int", 0} ; 
	Symb c = {'c' , 3, 1, "int", 0} ; 

	ajouter_symbole (a) ; 
	ajouter_symbole (b) ; 	
	ajouter_symbole (c) ; 

	int symb_cherche = rechercher_symbole ('a') ; 
	printf("Trouvé: %d \n", symb_cherche); 

	return 0;
}
