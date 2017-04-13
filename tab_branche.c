#include "tab_branche.h"

int sommet_tab_branche=0;
int sommet_tab_ended=0;

void ajouter_branche (char nom[20],int ligne, int nb_instr,int prog_prof) {
  struct Branche branche;
  branche.nom=(char *)malloc(20*sizeof(char));
  strcpy(branche.nom,nom);
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
  if (get_nb_instr_tab_branche(prog_prof)!=0){
    //printf("adr: %d ; nb_instruct : %d\n",Tab_branche[sommet_tab_branche-1].adr,Tab_branche[sommet_tab_branche-1].nb_instruct );
    Tab_ended[sommet_tab_ended]=Tab_branche[sommet_tab_branche-1];
    sommet_tab_ended++;
  }
  sommet_tab_branche --;
}

void increment_instr(int prog_prof, int nb){
  int i;
  if (sommet_tab_branche>0){
    for (i=prog_prof+1;i>=0;i--){
      Tab_branche[i].nb_instruct=Tab_branche[i].nb_instruct + nb;
      //printf("adr: %d ; nb_instruct : %d\n",Tab_branche[i].adr,Tab_branche[i].nb_instruct );
    }
  }
}

int get_adr_tab_branche( int prog_prof){
  return Tab_branche[prog_prof].adr;
}

int get_nb_instr_tab_branche( int prog_prof){
  return Tab_branche[prog_prof].nb_instruct;
}

void get_nom_tab_branche(int prog_prof,char buf[]){
  strcpy(buf,Tab_branche[prog_prof].nom);
}

void set_ligne_tab_branche(int ligne,int prof){
//  int i=rechercher_element_tab_branche(prof);
  Tab_branche[prof].adr=ligne;
}


int rechercher_element_tab_ended(int lig){
	int i=0;
	while(Tab_ended[i].adr!=lig){
		i++;
	}
	return i;
}

int tab_ended_is_empty(int i){
  if (i>sommet_tab_ended)
    return 1;
  else
    return 0;
}

int get_nb_instr_tab_ended( int i){
	return Tab_ended[i].nb_instruct;
}

int get_adr_tab_ended( int i){
	return Tab_ended[i].adr;
}

void get_nom_tab_ended(int i, char buf[]){
  strcpy(buf,Tab_ended[i].nom);
}
