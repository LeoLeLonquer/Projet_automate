#include "tab_branche.h"

int main (void) {

	/*branche a = {5 , 0, 0} ;
	branche b = {"b" , 1, 0} ;
	branche c = {"c" , 1, 0} ;
	branche d = {"d" , 1, 1} ;
	branche e = {"e" , 1, 1} ;*/


	ajouter_branche (5 , 0,0) ;
	increment_instr(0,10);
	ajouter_branche (6 , 0,1) ;
	ajouter_branche (8 , 55,2) ;
	increment_instr(2,10);
	ajouter_branche (10, 0,3) ;
	ajouter_branche (15, 0,4) ;
	ajouter_branche (18 , 0,5) ;
	ajouter_branche (19, 0,6) ;

	increment_instr(6,10);


	// int prog_prof=4;
	// printf("Profondeur programme : %d\n" , prog_prof);
	// int i=0;
	// for (i=0; i<sommet_tab_branche;i++){
	// 	printf("Indice : %d\n" ,i);
	// 	printf("nombre instr : %d\n" , get_nb_instr_tab_branche(i));
  // }

	retirer_branche(6);
	retirer_branche(5);
	retirer_branche(4);
	retirer_branche(3);
	retirer_branche(2);
	retirer_branche(1);
 	int indice;
	int adr;
	int nb_instr;

	int i;
  for (i=0;i++;i<=6){
		printf("%d\n", Tab_branche[i].adr);
	}
	/*indice=rechercher_element_tab_ended(8);
	adr= get_adr_tab_ended(indice);
	nb_instr=get_nb_instr_tab_ended(indice);*/

	//printf("adr : %d ; nb_instr : %d\n",adr,nb_instr);




	return 0;
}
