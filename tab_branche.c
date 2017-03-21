#include "tab_branche.h"

int indice_tab_ended=0;
int ligne=0;
int prog_prof=0;

void ajouter_branche () {
  struct Branche branche;
  branche.adr=ligne;
  branche.nb_instruct=0;
  branche.prof=prog_prof;
  if (prog_prof >= 1024) {
    printf("Attention! Tableau des branchements plein \n") ;
  }
  else {
    Tab_branche[prog_prof] = branche ;
    prog_prof ++;
  }
}

void retirer_branche () {
  save_branche();
  prog_prof --;
}

void increment_instr(int nb){
  int i=prog_prof;

  while(prog_prof>Tab_branche[i].prof){
    Tab_branche[i].nb_instruct=Tab_branche[i].nb_instruct + nb;
    i--;
  }
}

void increment_ligne(int nb){
  ligne=ligne+nb;
}

int get_ligne(int prof){
  return Tab_branche[prof].adr;
}

int get_nb_instr(int prof){
  return Tab_branche[prof].nb_instruct;
}

void save_branche(){
  Tab_ended[indice_tab_ended]=Tab_branche[prog_prof];
  indice_tab_ended++;
}
