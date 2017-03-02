#include <stdio.h>
#include <stdlib.h> 

typedef struct Symb Symb;
struct Symb { 
	char id;
	int addr;  // sera aussi la position dans le tableau 
	int init; 
	char* type; 
	int profondeur; 
} ; 

Symb Tab_symbs[1024] ; 
static int nb_elts = 0 ; 

void ajouter_symbole (Symb symb) ; 
void retirer_symbole (int profondeur) ; // ??????
int rechercher_symbole (char id); // renvoie l'id du symbole dans le tableau? un bool? 
int lire (Symb symb);

