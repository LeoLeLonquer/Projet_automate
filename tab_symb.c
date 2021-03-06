#include "tab_symb.h"

int nb_elts=0;

int rechercher_symbole (char id[16]) { // retourne addr de symbole cherché
	int i = nb_elts -1;
	int ok = 0;

	while ((i >=0) && (ok == 0)) { // on remonte dans le tab car dernière valeur = celle à utiliser
		if (!strcmp(Tab_symbs[i].id,id))
			ok=1;
		else
			i-- ;
	}
	return i;
}


void ajouter_symbole (Symb symb) {
	//if (rechercher_symbole(symb) == 0) {
		if (nb_elts >= 1024) {
			printf("Attention! tableau plein \n") ;
		}
		else {
			Tab_symbs[nb_elts] = symb;
			nb_elts ++ ;
		}
}

void retirer_symbole (int profondeur) {

	int ok = 0;

	while (!ok  && nb_elts>0 ) {
		if (Tab_symbs[nb_elts-1].profondeur == profondeur) {
			nb_elts --;
		}
		else
			ok = 1;
	}
}

void initialiser_symbole(char id[16]){
	int pos = rechercher_symbole(id);
	Tab_symbs[pos].init=1;
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
*/
