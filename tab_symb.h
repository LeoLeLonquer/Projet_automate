#include <stdio.h>
#include <stdlib.h>

typedef struct Symb Symb;
struct Symb {
	char id[16];
	//int addr;  // sera aussi la position dans le tableau
	int init;
	int profondeur;
} ;

Symb Tab_symbs[1024] ;
extern int nb_elts;

void ajouter_symbole (Symb symb) ; //ajoute un symbole
void retirer_symbole (int profondeur) ; // retire tous les symboles d'une même profondeur
int rechercher_symbole (char id[16]); // renvoie l'id du symbole dans le tableau? un bool?
void initialiser_symbole(char id[16]); //modifie la valeur d'initialisation
