#include "tab_branche.h"

int sommet_tab_branche=0;
int index_tab_ended=0;

void ajouter_branche (int ligne, int nb_instr,int prog_prof) {
  struct Branche branche;
  branche.adr=ligne;
  branche.nb_instruct=nb_instr;
  branche.prof=prog_prof;
  if (prog_prof >= 1024) {
    printf("Attention! Tableau des branchements plein \n") ;
  }
  else if (prog_prof>sommet_tab_branche+1){
    printf("Erreur, profondeur trop grande \n");
  }
  else if (prog_prof<sommet_tab_branche){
    printf("Erreur, profondeur trop petite \n");
  }
  else {
    Tab_branche[sommet_tab_branche] = branche ;
    sommet_tab_branche ++;
  }
}

void retirer_branche (int prog_prof) {
  if (get_nb_instr_tab_branche(prog_prof)!=0)
    save_branche();
  sommet_tab_branche --;
}

void increment_instr(int prog_prof, int nb){
  int i;
  for (i=prog_prof+1;i--;i>=0){
    Tab_branche[i].nb_instruct=Tab_branche[i].nb_instruct + nb;
  }
}


int get_adr_tab_branche( int prog_prof){
  return Tab_branche[prog_prof].adr;
}

int get_nb_instr_tab_branche( int prog_prof){
  return Tab_branche[prog_prof].nb_instruct;
}

int rechercher_element_tab_ended(int adr){
	int i=0;
	while(Tab_ended[i].adr!=adr){
		i++;
	}
	return i;
}

int get_nb_instr_tab_ended( int i){
	return Tab_ended[i].nb_instruct;
}

int get_adr_tab_ended( int i){
	return Tab_ended[i].adr;
}


void save_branche(){
  Tab_ended[index_tab_ended]=Tab_branche[sommet_tab_branche];
  index_tab_ended++;
}
