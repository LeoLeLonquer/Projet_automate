%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tab_symb.h"
#include "tab_fun.h"
#include "tab_branche.h"

char *progname;
int yylex(void);
void yyerror(const char *s);

static int ligne =0;
static int prof=0;

static FILE *out;

//int tmp[]; //tableau des variables temporaires: si tmp[1]=0 => tmp1 inutilisé, tmp[1]>0 => tmp1 utilisé

// La pile de variables temporaires s'empile dans le tableau des symboles
static int sommet_tmp=0;// à utiliser lors de la gestion d'expression tel que a= 5+3+2 (sans parenthésage pour l'instant)

static int indiceFun; //utilisé surtout pour compter le nombre d'arguments

static int sommet_while=0;

int increment_ligne(int x){
	ligne=ligne+x;
}


char * expr_arith(char instr[16],char dollardollar[16],char dollar1[16],char dollar2[16]){
	int adr1 =rechercher_symbole(dollar1);
	if (adr1!=-1)
  	fprintf(out,"\t%d : LOAD R0 [ebp+%d]\n",ligne, adr1);
	else
		printf("Erreur lors de la recherche de dollar1\n");

	int adr2=rechercher_symbole(dollar2);
	if (adr1!=-1)
			fprintf(out,"\t%d : LOAD R1 [ebp+%d]\n",ligne+1, adr2);
	else
			printf("Erreur lors de la recherche de dollar2\n");

  if (strcmp(instr,"ADD")==0){ fprintf(out,"\t%d : ADD R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"SUB")==0){fprintf(out,"\t%d : SUB R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"DIV")==0){fprintf(out,"\t%d : DIV R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"MUL")==0){fprintf(out,"\t%d : MUL R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"OR")==0){fprintf(out,"\t%d : OR R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"AND")==0){fprintf(out,"\t%d : AND R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"EQU")==0){fprintf(out,"\t%d : EQU R0 R0 R1\n",ligne+2);}

  fprintf(out,"\t%d : STORE ebp+%d R0\n", ligne+3,adr1);
  increment_ligne(4);
  increment_instr(prof,4);

	sommet_tmp--;
  return dollar1;
}

%}

%error-verbose

%union
{
		int number;
    char string[100];
}

%token TMain TInt TIf TWhile TConst ToBracket TcBracket
%token ToParenthesis TcParenthesis ToCrochet TcCrochet
%token TSemicolon TEqual TComma TPlus TMinus TSlash
%token TStar TReturn TEquality TAnd TOr TInclude TElse

%token <number> TNumber
%token <string> TId

%type <string> Exp
%type <string> Invoc

%left TPlus TMinus
%left TStar TSlash
%left TAnd TOr
%left TEquality

%start Prg    /*définit l'axiome de départ*/

%%
Prg: Fonctions   //Règle inutile mais qu'on garde qd même pour faire joli
							{
							}
		;

Fonctions : Main          //Le Main doit se situer à la fin du programme
 			|Fonction Fonctions
			;

Fonction: TInt TId {ligne=0;
										prof=0;
										int indiceFun= rechercher_fun($2);
										if (indiceFun!=-1)
											printf("Fonction déjà déclarée !\n");
										else{
											ajouter_fun($2,0);
											int indiceFun= rechercher_fun($2);
										}
										fprintf(out, "\n%s :\n", $2);

										//on crée une valeur en haut de la pile
										ajouter_symbole("SavedEbp",1,0);
										int adrSavedEpb= rechercher_symbole("SavedEbp");

										fprintf(out,"\t%d : STORE ebp [ebp+%d]\n",ligne,adrSavedEpb); //on enregistre ebp en haut de la pile
										fprintf(out,"\t%d : AFC ebp ebp+%d+1\n",ligne+1,adrSavedEpb); // on met ebp en haut de la pile

										increment_ligne(2);
									}
					ToParenthesis Args {int nbArg=get_nbArg(indiceFun);
	 				 										int i;
	 														char nom[16];
	 														for (i=0;i<nbArg;i++){
	 															get_nomArg_by_numero(indiceFun,i,nom);
	 															ajouter_symbole(nom,1,0);
	 															int adrSymb= rechercher_symbole(nom);

	 															fprintf(out,"\t%d : LOAD R0 [ebp-%d]\n",ligne,nbArg-i );//on va chercher le premier paramètre
	 															fprintf(out,"\t%d : STORE ebp+%d R0\n",ligne+1,adrSymb);//on l'enregistre dans une adresse locale à la fonction comme une var normale

																increment_ligne(2);
															}
														}
					TcParenthesis Body {
															int nbArg_and_oldEbp=get_nbArg(indiceFun)+1; //le +1 correspond à l'espace pris par oldEbp
															fprintf(out,"\t%d : AFC R1 %d\n",ligne,nbArg_and_oldEbp);//on enregistre le nombre de parmètre pour ensuite faire une soustraction
															fprintf(out,"\t%d : SUB esp ebp R1\n",ligne+1 );//on rétablie esp=ebp-nbarg-1;

															fprintf(out,"\t%d : LOAD R0 [ebp-1]\n",ligne+2);//on va chercher l'ancien ebp
															fprintf(out,"\t%d : MOV ebp R0\n",ligne+3);//on rétablie l'ancien ebp

															fprintf(out,"\t%d : RET\n",ligne+4);//on revient à la routine précédente

															increment_ligne(5);

															retirer_symbole(0); //on vide la table des symboles
														 }
				;


//TODO gestion des arguments du main ???
Main : TInt TMain { ligne=0;
										prof=0;
									fprintf(out, "\nstart :\n");
									fprintf(out, "\t%d : AFC ebp 0 \n",ligne);

									increment_ligne(1);
									}
			 ToParenthesis Args TcParenthesis Body {retirer_symbole(0); //on vide la table des symboles
				 																			fprintf(out, "\t%d : RET \n",ligne);
																							increment_ligne(1);
			 																				}
			;


Args: /* epsilon*/
	| Arg ListeArgs
	;

ListeArgs: TComma Arg ListeArgs
		     | /*epsilon*/
 		     ;

Arg : TInt TId {ajouter_arg(indiceFun,$2);
							}
    ;



Body :  ToBracket Instrs TcBracket
		;

Instrs : /*epsilon*/
 		| Instr Instrs
    ;

Instr : Decl
        |If
        |While
        |Affect
        |Invoc
				|Return
        ;

Return : TReturn Exp {	int adrTmp= rechercher_symbole($2);
												fprintf(out,"\t%d : LOAD eax [ebp+%d]\n",ligne, adrTmp);
												//TODO faire un JMP jusqu'à la fin de la fonction ou écrire les trucs de fins de fonctions ici
												increment_ligne(1);
												increment_instr(prof,1);
											}


Invoc: TId ToParenthesis Params TcParenthesis TSemicolon 	{ fprintf(out,"\t%d : CALL %s\n", ligne, $1);

																				//on sauvegarde le contenu du registre de retour eax dans une variable nommée EAX
																					int adrEAX= rechercher_symbole("EAX");
																					if (adrEAX==-1){
																						 ajouter_symbole("EAX",1,prof);
																						 adrEAX=rechercher_symbole("EAX");
																					 }
																					 fprintf(out,"\t%d : STORE ebp+%d eax\n",ligne+1,adrEAX);

																					 increment_ligne(2);
																					 increment_instr(prof,2);
																					 strcpy($$,"EAX");;
			 																		}
      ;

Params : /*epsilon*/
        | Param
        | Param TComma ParamsNext
        ;

ParamsNext : Param
          | Param TComma ParamsNext
          ;

Param : Exp {
						int adrTmp= rechercher_symbole($1);

						ajouter_symbole("arg",1,prof); // on rajoute un symbole en haut de la table des symboles pour obtenir le haut de la pile
						int adrArg=rechercher_symbole("arg");

						fprintf(out,"\t%d : LOAD R0 [ebp+%d]\n",ligne, adrTmp); //récupère la var
						fprintf(out,"\t%d : STORE ebp+%d R0\n",ligne+1,adrArg); //on enregistre en haut de la pile pour la passage de la fonction

						increment_ligne(2);
						increment_instr(prof,2);
					}
					;

If : TIf ToParenthesis Exp {	int adrSymb= rechercher_symbole($3);
															fprintf(out,"\t%d : LOAD RZ %d\n",ligne, adrSymb);
															increment_ligne(1);
															increment_instr(prof,1);
															printf("ligne : %d , prof : %d\n", ligne, prof );
															ajouter_branche("JMPZ", ligne,1,prof);
      												fprintf(out,"XMP            \n");
															increment_ligne(1);
															increment_instr(prof,1);
															prof++;
														}
		TcParenthesis Body Else

Else : 			{prof--;
						fermer_branche(prof);
						}
    | TElse {ajouter_branche("JMP",ligne-1,1,prof);
						 fprintf(out,"XMP                   \n");}
		 	Body   {prof--;
							fermer_branche(prof);
				  		}
    ;

While : TWhile {char charnb[10];   //on commence le branchement ici qui nous permettra de compter
																	// le nombre d'instruction y compris de la condition
								ajouter_branche("JMPZ",ligne,1,prof);
							}
		 ToParenthesis Exp {int adrSymb= rechercher_symbole($4);
													 fprintf(out,"\t%d : LOAD RZ %d\n",ligne, adrSymb);
													 fprintf(out,"XMP             \n");
													 increment_ligne(2);
													 increment_instr(prof,2);
													 sommet_while++;
													 prof++;
													}
		TcParenthesis Body {int adrDebWhile=get_adr_tab_branche(prof-1);
														 increment_instr(prof,1);
														 fermer_branche(prof-1);
														 fprintf(out,"\t%d : JMP %d\n",ligne, adrDebWhile); //JMP jusqu'au debut du calcul de la condition
											    	 increment_ligne(1);
														 prof --;
														 sommet_while--;
													 }

      ;


//toutes les expressions vont être traduites en variables temporaires
Exp : TId {//création nouvelle variable temporaire
					 char charnb[10];
					 char tmp[20]="tmp";
					 sprintf(charnb,"\t%d",sommet_tmp);
					 strcat(tmp, charnb);

					 int adrTmp= rechercher_symbole(tmp);
					 if (adrTmp==-1){
					 		ajouter_symbole(tmp,1,prof);
	 				    adrTmp=rechercher_symbole(tmp);
					 }
					 sommet_tmp++;

					 int adrId=rechercher_symbole($1);
					 //enregistrement du contenu du TId à l'adresse de la var tmp
					 fprintf(out,"\t%d : LOAD R0 [ebp+%d]\n",ligne, adrId);
			 		 fprintf(out,"\t%d : STORE ebp+%d R0\n",ligne+1,adrTmp);

					 increment_ligne(2);
					 increment_instr(prof,2);
				 	 strcpy($$,tmp);}

| TNumber {	//création nouvelle variable temporaire
					 char charnb[10];
				   char tmp[20]="tmp";
					 sprintf(charnb,"\t%d",sommet_tmp);
					 strcat(tmp, charnb);

					 int adrTmp= rechercher_symbole(tmp);
					 if (adrTmp==-1){
					 		ajouter_symbole(tmp,1,prof);
 					 		adrTmp=rechercher_symbole(tmp);
				 		}
						sommet_tmp++;
					 //enregistrement de TNumber à l'adresse de la var tmp
					 fprintf(out,"\t%d : AFC R0 %d\n",ligne, $1);
		 			 fprintf(out,"\t%d : STORE ebp+%d R0\n",ligne+1,adrTmp);

					 increment_ligne(2);
					 increment_instr(prof,2);

					 strcpy($$,tmp);
				 }
|Invoc  {strcpy($$,$1);}
| Exp TPlus Exp { strcpy($$,expr_arith("ADD",$$,$1,$3));}
| Exp TMinus Exp {  strcpy($$, expr_arith("SUB", $$,$1, $3));}
| Exp TStar Exp {  strcpy($$, expr_arith("MUL", $$,$1, $3));}
| Exp TSlash Exp {  strcpy($$, expr_arith("DIV", $$,$1, $3));}
| Exp TOr Exp {  strcpy($$, expr_arith("OR",$$, $1, $3));}
| Exp TAnd Exp {  strcpy($$, expr_arith("AND",$$, $1, $3));}
| Exp TEquality Exp {  strcpy($$, expr_arith("EQU",$$, $1, $3));}
;


Affect: TId TEqual Exp TSemicolon
	{ int adrId =rechercher_symbole($1);
		if (adrId ==-1){
			yyerror("Variable non déclarée");
		}
		else {
			initialiser_symbole(adrId);
			int adrExp= rechercher_symbole($3);

			fprintf(out,"\t%d : LOAD R0 [ebp+%d]\n",ligne, adrExp);
			fprintf(out,"\t%d : STORE ebp+%d R0\n",ligne+1,adrId);

			increment_ligne(2);
			increment_instr(prof,2);

			sommet_tmp--; //plus besoin de la var tmp Exp
			}
	}
	;


Decl : TInt Decl1 DeclX TSemicolon ;
Decl1 : TId {ajouter_symbole($1,0,prof);}
	| TId TEqual Exp {
										ajouter_symbole($1,1,prof);
										int adrId=rechercher_symbole($1);
										int adrExp= rechercher_symbole($3);
										fprintf(out,"\t%d : LOAD R0 [ebp+%d]\n",ligne, adrExp);
										fprintf(out,"\t%d : STORE ebp+%d R0\n",ligne+1,adrId);
										increment_ligne(2);
										increment_instr(prof,2);

										sommet_tmp--; //plus besoin de la var tmp Exp
										}
	;

DeclX : /*epsilon*/
	| TComma Decl1 DeclX
	;
%%
void yyerror(const char *s ){
fprintf(stderr,"%s\n",s);
}
int main(void){
	out = fopen("./out.asm","w+");
	yyparse();

	printf("********************Fin parsage********************\n");
	int lig=-1;
	int adr=0;
	int nb_instr;
	char *nom=(char *)malloc(20*sizeof(char));
	char c;
	int eof=0;
 	char * s=malloc(2000+1);
	rewind(out);

	int indice=0;
	int j=0;

	int sommet_tab_branche=get_sommet_tab_branche();

	for (indice=0;indice<sommet_tab_branche;indice++){
		adr=get_adr_tab_branche_with_indice(indice);
		c=fgetc(out);
		if (c==EOF)
		eof=1;

		while (!eof && c!='X') { //correspond à une ligne laissée pour un jump
			//printf("caractere :%c\n", c);
			c=fgetc(out);
			if (c==EOF)
			eof=1;
			else if (c=='\n'){
				lig++;
				c=fgetc(out);
				if (c!='\t' && c!='X'){
					lig=-1;
				}
			}

		}

		fseek(out,-2*sizeof(char), SEEK_CUR);

		get_nom_tab_branche_with_indice(indice,nom);
		nb_instr=get_nb_instr_tab_branche_with_indice(indice);

		fprintf(out,"\n\t%d : %s %d", lig,nom, lig+nb_instr);
		fflush(out);

	}

	printf("==============\n" );
	int i;
	for (i=0;i<5;i++){
		printf("Indice : %d\n" ,i);
		printf("adr: %d ; nb_instruct : %d, prof: %d \n", get_adr_tab_branche_with_indice(i),get_nb_instr_tab_branche_with_indice(i),get_prof_with_indice(i));
	}
	fclose(out);
	return 0;

}
