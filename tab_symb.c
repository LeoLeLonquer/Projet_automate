#include "tab_symb.h"


int rechercher_symbole (Symbs symb) {
	int i = 0; 
	int ok = 0; 
	
	while ((i < compteur) && (ok == 0)) { 
		if (Tab_symbs[i].id == symb.id)
			ok=1; 
		else 
			i++ ; 
	}
	return i; 
}


void ajouter_symbole (Symbs symb) {
	//if (rechercher_symbole(symb) == 0) { 
		if (compteur >= 1024)
			printf("Attention! tableau plein \n") ;  
		}
		else { 
			Tab_symbs[compteur] = symb; 
			compteur++ ; 	
		}
}
 
void retirer_symbole (Symbs symb) {

	compteur --; 
}

int lire (Symbs symb) { // ex: lire(a) renvoie l'adresse de a 

} 
/*
// rajouter dans le yacc les bouts de code pour traiter : "{} " --> si a = b+c+d alors
//  besoin que de deux vars tporaires; alors que si a= b+ (c+(d+e))) alors il faut 
// autom à pile, pour gérer ça. Il faudra autant de vars tportaires qu'il y a de parenthèses ouvrantes. 
// profondeur = nombre d'accolades avant: 
// main { int a ; if..{{{ int b ; --> a = profondeur 0, b = profondeur 3 
// il faut supprimer les symboles de la table une fois accolade fermée à la pronfdeur de blc de l'accolade --> fin de bloc
	ex: 	main (){
				int a ; 
					if (truc) {
						int b, c, d ; 
						b = c+d ; 
				}
			}
dans l'exmple ci-dessus, il faut supprimer b, c et d de la table à la fin du if. 
// aussi dès qu'on supprime une var tporaire 
