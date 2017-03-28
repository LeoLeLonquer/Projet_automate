#include "tab_branche.h"

int sommet_tab_branche=0;
int sommet_tab_ended=0;

void ajouter_branche (int ligne, int nb_instr,int prog_prof) {
  struct Branche branche;
  branche.adr=ligne;
  branche.nb_instruct=nb_instr;
  branche.prof=prog_prof+1;
  if (prog_prof >= 1024) {
    printf("Attention! Tableau des branchements plein \n") ;
  }
  else {
    Tab_branche[sommet_tab_branche] = branche ;
    sommet_tab_branche ++;
  }
}

void retirer_branche (int prog_prof) {
  if (get_nb_instr(prog_prof)!=0)
    save_branche();
  sommet_tab_branche --;
}

void increment_instr(int prog_prof, int nb){
  int i=prog_prof;
  if (prog_prof!=0){
    while(prog_prof>Tab_branche[i].prof && i>0){
      Tab_branche[i].nb_instruct=Tab_branche[i].nb_instruct + nb;
      i--;
    }
  }
}


int get_ligne(int prog_prof){
  return Tab_branche[prog_prof].adr;
}

int get_nb_instr(int prog_prof){
  return Tab_branche[prog_prof].nb_instruct;
}

void save_branche(){
  Tab_ended[sommet_tab_ended]=Tab_branche[sommet_tab_branche];
  sommet_tab_ended++;
}
