#include "tab_branche.h"

int main (void) {

	/*branche a = {5 , 0, 0} ;
	branche b = {"b" , 1, 0} ;
	branche c = {"c" , 1, 0} ;
	branche d = {"d" , 1, 1} ;
	branche e = {"e" , 1, 1} ;*/


	ajouter_branche (5 , 0) ;
	increment_instr(10);
	ajouter_branche (6 , 0) ;
	ajouter_branche (8 , 0) ;
	increment_instr(10);
	ajouter_branche (10, 0) ;
	ajouter_branche (15, 0) ;
	increment_instr(10);
	printf("Profondeur programme : %d\n" , prog_prof);
	printf("nombre instr : %d\n" , get_nb_instr(prog_prof-4));
	printf("nombre instr : %d\n" , get_nb_instr(prog_prof));


/*
	printf("nombre d'éléments : %d\n" , nb_elts);
	printf("Trouvé: %d \n", symb_cherche);
	retirer_symbole(0);
	printf("nombre d'éléments : %d\n" , nb_elts);
*/
	return 0;
}
