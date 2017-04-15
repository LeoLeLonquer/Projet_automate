#include "tab_branche.h"

int sommet_tab_branche=0;
//int sommet_tab_ended=0;

void ajouter_branche (char nom[20],int ligne, int nb_instr,int prog_prof) {
  struct Branche branche;
  branche.nom=(char *)malloc(20*sizeof(char));
  strcpy(branche.nom,nom);
  branche.adr=ligne;
  branche.nb_instruct=nb_instr;
  branche.prof=prog_prof;
  branche.closed=0;
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

void fermer_branche (int prog_prof) {
    int indice= rechercher_element_tab_branche(prog_prof);
    //printf("adr: %d ; nb_instruct : %d\n",Tab_branche[sommet_tab_branche-1].adr,Tab_branche[sommet_tab_branche-1].nb_instruct );
    Tab_branche[indice].closed=1;
}

void increment_instr(int prog_prof, int nb){
  int i;
  if (sommet_tab_branche>0){
    for (i=sommet_tab_branche;i>=0;i--){
      if (!Tab_branche[i].closed && Tab_branche[i].prof<prog_prof )
        Tab_branche[i].nb_instruct=Tab_branche[i].nb_instruct + nb;
      //printf("adr: %d ; nb_instruct : %d\n",Tab_branche[i].adr,Tab_branche[i].nb_instruct );
    }
  }
}

int get_sommet_tab_branche(){
  return sommet_tab_branche;
}

int get_adr_tab_branche( int prog_prof){
  int indice= rechercher_element_tab_branche(prog_prof);
  return Tab_branche[indice].adr;
}

int get_nb_instr_tab_branche( int prog_prof){
  int indice= rechercher_element_tab_branche(prog_prof);
  return Tab_branche[indice].nb_instruct;
}

void get_nom_tab_branche(int prog_prof,char buf[]){
  int indice= rechercher_element_tab_branche(prog_prof);
  strcpy(buf,Tab_branche[indice].nom);
}

void set_ligne_tab_branche(int ligne,int prog_prof){
//  int i=rechercher_element_tab_branche(prof);
 int indice= rechercher_element_tab_branche(prog_prof);
 Tab_branche[indice].adr=ligne;
}


int rechercher_element_tab_branche(int prog_prof){
	int i=sommet_tab_branche-1;
	while(Tab_branche[i].prof!=prog_prof && i>-1){
		i--;
	}
	return i;
}

int tab_branche_is_empty(int i){
  if (i>sommet_tab_branche)
    return 1;
  else
    return 0;
}

int get_adr_tab_branche_with_indice(int indice){
  return Tab_branche[indice].adr;
}

int get_nb_instr_tab_branche_with_indice( int indice){
  return Tab_branche[indice].nb_instruct;
}

void get_nom_tab_branche_with_indice(int indice,char buf[]){
  strcpy(buf,Tab_branche[indice].nom);
}
