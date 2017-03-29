#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Symb Symb;
struct Symb {
	char id[16];
	//int addr;  // sera aussi la position dans le tableau
	int init;
	int profondeur;
} ;

Symb Tab_symbs[1024] ;
extern int nb_elts;

int rechercher_symbole(char id[16]); //  retourne addr de symbole cherché
void ajouter_symbole (char id[16], int init, int prof) ; //ajoute un symbole
void retirer_symbole (int profondeur) ; // retire tous les symboles d'une même profondeur
void initialiser_symbole(int pos); //modifie la valeur d'initialisation
