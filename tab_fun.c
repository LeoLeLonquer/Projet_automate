#include "tab_fun.h"

int sommet_tab_fun=0;

int rechercher_fun(char id[16]) {
	int i = sommet_tab_fun -1;
	int ok = 0;

	while ((i >=0) && (ok == 0)) { // on remonte dans le tab car dernière valeur = celle à utiliser
		if (!strcmp(Tab_fun[i].id,id))
			ok=1;
		else
			i-- ;
	}
	return i;
}


void ajouter_fun (char id[16], int adrDeb, int nbArg) {
	struct Fun fun;
	strcpy(fun.id,id);
	fun.adrDeb=adrDeb;
	fun.nbArg=nbArg;
	if (sommet_tab_fun >= 1024) {
		printf("Attention! tableau plein \n") ;
	}
	else {
		Tab_fun[sommet_tab_fun] = fun;
		sommet_tab_fun ++ ;
	}
}

void increment_arg(int indice,int nb){
	Tab_fun[indice].nbArg=Tab_fun[indice].nbArg+nb;
}

int get_adrDeb(int indice){
	return Tab_fun[indice].adrDeb ;
}

int get_nbArg(int indice){
	return Tab_fun[indice].nbArg;
}
