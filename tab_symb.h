#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Symb Symb;
struct Symb {
	char id[16];
	//int adr;  // sera aussi la position dans le tableau qui est l'adresse relative de l'élément par rapport à ebp
	int init;
	int profondeur;
} ;

Symb Tab_symbs[1024] ;
extern int nbElts;


int rechercher_symbole(char id[16]); //  retourne l'adr absolue de symbole cherché
void ajouter_symbole (char id[16], int init, int prof) ; //ajoute un symbole
void retirer_symbole (int profondeur) ; // retire tous les symboles d'une même profondeur
void initialiser_symbole(int pos); //modifie la valeur d'initialisation
int get_nbElts(); //renvoie nbElts;
