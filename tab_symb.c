#include "tab_symb.h"

int nbElts=0;


int rechercher_symbole(char id[16]) { // retourne adr de symbole cherché
	int i = nbElts -1;
	int ok = 0;

	while ((ok == 0) && (0<=i)) { // on remonte dans le tab car dernière valeur = celle à utiliser
		if (!strcmp(Tab_symbs[i].id,id))
			ok=1;
		else
			i-- ;
	}
	return i;
}


void ajouter_symbole (char id[16], int init, int prof) {
	//if (rechercher_symbole(symb) == 0) {
	struct Symb symb;
	strcpy(symb.id,id);
	symb.init=init;
	symb.profondeur=prof;
	if (nbElts >= 1024) {
		printf("Attention! tableau plein \n") ;
	}
	else {
		Tab_symbs[nbElts] = symb;
		nbElts ++ ;
	}
}

void retirer_symbole (int profondeur) {
	int ok = 0;
	while (!ok  && nbElts>0 ) {
		if (Tab_symbs[nbElts-1].profondeur == profondeur) {
			nbElts --;
		}
		else{
			ok = 1;
		}
	}
}

void initialiser_symbole(int pos){
	if (pos>=0){
		Tab_symbs[pos].init=1;
	}
}

int get_nbElts(){
	return nbElts;
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
