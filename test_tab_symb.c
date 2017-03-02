#include "tab_symb.h"

int main (void) {  

	Symb a = {"a" , 1, 0} ; 
	Symb b = {"b" , 1, 0} ; 
	Symb c = {"c" , 1, 0} ; 
	Symb d = {"d" , 1, 1} ; 
	Symb e = {"e" , 1, 1} ;

 
	ajouter_symbole (a) ; 
	ajouter_symbole (b) ; 
	printf("nombre d'éléments : %d\n" , nb_elts); 	
	ajouter_symbole (c) ;
	//ajouter_symbole (d) ; 
	//ajouter_symbole (e) ;  
	

	printf("nombre d'éléments : %d\n" , nb_elts); 
	int symb_cherche = rechercher_symbole ("b") ; 
	printf("Trouvé: %d \n", symb_cherche); 
	retirer_symbole(0);
	printf("nombre d'éléments : %d\n" , nb_elts); 

	return 0;
}
