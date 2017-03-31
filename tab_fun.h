#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Fun Fun;
struct Fun {
	char id[16];
	int adrDeb;
	int nbArg;
} ;

Fun Tab_fun[1024] ;
extern int sommet_tab_fun;

int rechercher_fun(char id[16]); //  retourne l'indice dans tab_fun de la fonction recherchée
void ajouter_fun (char id[16], int adrDeb, int nbArg) ; //ajoute une fonction
void increment_arg(int indice,int nb); //incremente le nb d'argument de nb de la fonction à l'indice indice de Tab_fun
int get_adrDeb(int indice); //renvoie l'adresse de début de la fonction en fonction de son indice dans le tableau
int get_nbArg(int indice);//renvoie le nombre d'argument de la fonction
