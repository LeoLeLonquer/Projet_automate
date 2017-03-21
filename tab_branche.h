#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*================================================================
Ce tableau permet de compter le nombre d'instructions assembleur
dans le corps des branchements if, des else, pour ensuite pourvoir imprimer
les commandes jump avec la bonne adresse.
================================================================*/


/*%%%%%%%%%%%%%%IMPORTANT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Laisser une ligne libre (printf("\n")) pour les
 futures branchements jump dans le fichier assembleur.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

typedef struct Branche Branche;
struct Branche {
	int adr; //numéro de la ligne dans l'assembleur
  int nb_instruct; //nombre d'instructions associées à ce branchement
	int prof; //compteur du nombre d'accolades ouvertes.
							//Si prof>prog_prof =>incrémentation de nb_instruct
							//si prof=prog_prof => fin incrémentation
} ;

Branche Tab_branche[1024] ;//tab des branchements dans l'analyse dynamique
Branche Tab_ended[1024];//sauvegarde des branchements et des lignes complétées
														//pour les insérer dans les lignes  prévues
extern int indice_tab_ended;
extern int ligne;   //numéro courant de la ligne dans le programme assembleur
extern int prog_prof; //profondeur courante dans le programme assembleur
 											//prog_prof=prog_prof++ si '{' rencontré
											//prog_prof=prog_prof-- si '}' rencontré

void increment_instr(int nb); // incrémente 'nb_instr' de 'nb' pour les branchements tels que prog_prof>branche.prof
void increment_ligne(int nb); // incrémente 'ligne' de 'nb'

void ajouter_branche () ; //ajoute un branchement {ligne,0,prog_prof} à Tab_branche,
void retirer_branche () ; // retire les branchements de la profondeur prog_prof

int get_ligne(int prof); //permet de récupérer la ligne du jump à effectuer
int get_nb_instr(int prof); //permet de récupérer nb_instr du branchement à la profondeur prof

void save_branche(); //sauvegarde une branchement dans Tab_ended
