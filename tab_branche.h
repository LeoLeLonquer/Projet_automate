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
	char * nom;
	int adr; //numéro de la ligne dans l'assembleur
  int nb_instruct; //nombre d'instructions associées à ce branchement
	int prof; //compteur du nombre d'accolades ouvertes.
							//Si prof>prog_prof =>incrémentation de nb_instruct
							//si prof=prog_prof => fin incrémentation
} ;

Branche Tab_branche[1024] ;//tab des branchements dans l'analyse dynamique
Branche Tab_ended[1024];//sauvegarde des branchements et des lignes complétées
														//pour les insérer dans les lignes  prévues

extern int sommet_tab_branche; //indice sur le sommet de tab_branche équivalent à la profondeur actuelle
extern int sommet_tab_ended;

//extern int ligne;  %remplacé par ligne dans parserY.y //numéro courant de la ligne dans le programme assembleur
//extern int prog_prof;  %remplacé par prof dans parserY.y //profondeur courante dans le programme assembleur
 											//prog_prof=prog_prof++ si '{' rencontré
											//prog_prof=prog_prof-- si '}' rencontré

void increment_instr(int prog_prof, int nb); // incrémente 'nb_instr' de 'nb' pour les branchements tels que prog_prof>branche.prof

void ajouter_branche (char nom[20] ,int ligne, int nb_instr,int prog_prof) ; //ajoute un branchement {ligne,nb_instr,prog_prof+1} à Tab_branche,
void retirer_branche (int prog_prof) ; // retire les branchements de la profondeur prog_prof
																				// sauvegarde une branchement dans Tab_ended, automatique avec retirer_symbole


int get_adr_tab_branche( int prof); //permet de récupérer la ligne du jump à effectuer
int get_nb_instr_tab_branche( int prof); //permet de récupérer nb_instr du branchement à la profondeur prof
void get_nom_tab_branche(int prof,char buf[]); //renvoie le nom de l'instruction à effectuer

void set_ligne_tab_branche(int ligne,int prof);//permet de changer le numéro de branche pour le branchement à la profondeur prof


int rechercher_element_tab_ended( int lig); //renvoie l'adresse de l'élément recherché grâce à sa ligne

int tab_ended_is_empty(int i) ; // permet de savoir quand la table ne possède plus d'élément

int  get_nb_instr_tab_ended( int i); //i étant l'indice dans le tableau, donné par rechercher_element_tab_ended
int get_adr_tab_ended( int i);
void get_nom_tab_ended(int i,char buf[]);
