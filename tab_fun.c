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


void ajouter_fun (char id[16],int adrDeb, int nbArg) {
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


int get_nbArg(int indice){
	return Tab_fun[indice].nbArg;
}

void ajouter_arg(int indice, char nom[16]){
	int sommet=Tab_fun[indice].nbArg;
	int i;
	int flag=0;
	for (i=0;i<sommet;i++){
		if (strcmp(Tab_fun[indice].tabArg[i].nom,nom)==0){
			 flag=1;
		}
	}
	if (flag)
		printf("Erreur, deux paramètres avec le même nom ! \n");
	else {
		strcpy(Tab_fun[indice].tabArg[sommet].nom,nom);
		increment_arg(indice,1);
	}
}

int get_adrDeb(int indice){
	return Tab_fun[indice].adrDeb;
}

int get_numero_of_arg(int indice, char nom[16]){
	int sommet=Tab_fun[indice].nbArg;
	int i;
	for (i=0;i<sommet;i++){
		if (strcmp(Tab_fun[indice].tabArg[i].nom,nom)==0){
			return i;
		}
	}
	return -1;
}


void get_nomArg_by_numero(int indice,int numero, char buf[]){
	strcpy(Tab_fun[indice].tabArg[numero].nom,buf);
}
