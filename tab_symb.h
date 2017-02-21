#include <stdio.h>
#include <stdlib.h> 

typedef struct Symbs { 
	char id;
	int addr;  // sera aussi la position dans le tableau 
	int init; 
	char* type; 
	int profondeur; 
} ; 

Symbs[1024] Tab_symbs ; 
int compteur = 0; 


void ajouter_symbole (Symbs symb) ; 
void retirer_symbole (Symbs symb) ; // ??????
int rechercher_symbole (Symbs symb); // renvoie l'id du symbole dans le tableau? un bool? 
int lire (Symbs symb);  
 
