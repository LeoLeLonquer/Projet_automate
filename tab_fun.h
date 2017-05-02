#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Fun Fun;
typedef struct NomsArg NomsArg;

struct NomsArg{
		char nom[16];
};

struct Fun {
	char id[16];
	int adrDeb;
	int nbArg;
	NomsArg tabArg[100]; // ce tableau est nécessaire pour pouvoir effectuer un permier scan lors du parcours
													// des arguments et pour ensuite accéder aux données dans la pile car les args
													//sont empilées dans le sens inverse
} ;



Fun Tab_fun[1024] ;
extern int sommet_tab_fun;

int rechercher_fun(char id[16]); //  retourne l'indice dans tab_fun de la fonction recherchée
void ajouter_fun (char id[16],int adrDeb, int nbArg) ; //ajoute une fonction
void increment_arg(int indice,int nb); //incremente le nb d'argument de nb de la fonction à l'indice indice de Tab_fun
void ajouter_arg(int indice, char nom[16]); //ajoute un paramètre
int get_nbArg(int indice);//renvoie le nombre d'argument de la fonction
int get_adrDeb(int indice);//renvoie l'adresse de début de la fonction
int get_numero_of_arg(int indice, char nom[16]);//renvoie la position dans le tableau tabArg du nom
void get_nomArg_by_numero(int indice,int numero, char buf[]);//met dans buf le nom de la variable
