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


static int sommet_while=0;

static int indiceFun=0;
static int sommet_arg=0;
static int sommet_adrRet=0;

int increment_ligne(int x){
	ligne=ligne+x;
}



char * expr_arith(char instr[16],char dollardollar[16],char dollar1[16],char dollar2[16]){
	int adr1 =rechercher_symbole(dollar1);
	if (adr1!=-1)
  	fprintf(out,"%d : LOAD R0 %d\n",ligne, adr1);
	else
		printf("Erreur lors de la recherche de dollar1\n");

	int adr2=rechercher_symbole(dollar2);
	if (adr1!=-1)
			fprintf(out,"%d : LOAD R1 %d\n",ligne+1, adr2);
	else
			printf("Erreur lors de la recherche de dollar2\n");

  if (strcmp(instr,"ADD")==0){ fprintf(out,"%d : ADD R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"SUB")==0){fprintf(out,"%d : SUB R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"DIV")==0){fprintf(out,"%d : DIV R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"MUL")==0){fprintf(out,"%d : MUL R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"OR")==0){fprintf(out,"%d : OR R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"AND")==0){fprintf(out,"%d : AND R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"EQU")==0){fprintf(out,"%d : EQU R0 R0 R1\n",ligne+2);}

  fprintf(out,"%d : STORE %d R0\n", ligne+3,adr1);
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
    ;

Fonctions : Main          //Le Main doit se situer à la fin du programme
 			|Fonction Fonctions
			;

Fonction: TInt TId {ajouter_fun($2,ligne,0);
										indiceFun=rechercher_fun($2);}
					ToParenthesis Args TcParenthesis Body {	//création d'un espace mémoire pour l'adresse de retour de la fonction
																									char charnb[10];
																									char adrRet[20]="adrret";
																									sprintf(charnb,"%d",sommet_adrRet);
																									strcat(adrRet, charnb);

																									int adr_adrRet=rechercher_symbole(adrRet); //obtient l'adresse en mémoire de l'adresse de retour sauvegardée de la fonction
																									if (adr_adrRet==-1){
																										ajouter_symbole(adrRet,1,prof);
																									}

																									sommet_adrRet++;

																									//charge l'adresse de retour sauvegardée dans un registre et retourne à l'exécution avant l'appel de fonction
																									fprintf(out,"%d : LOAD R0 %d\n",ligne, adr_adrRet);
																									fprintf(out,"%d : MOV R0\n",ligne+1); //MOV= JMP à l'adresse contenue dans R0
																									increment_ligne(2);
																									increment_instr(prof,2);

																									sommet_arg=0;

																									}
				;

Main : TInt TMain {sommet_adrRet=0;
									}
			 ToParenthesis Args TcParenthesis Body
			;


Args: /* epsilon*/
	| Arg ListeArgs {increment_arg(indiceFun,1);}
	;

ListeArgs: TComma Arg ListeArgs  {increment_arg(indiceFun,1);}
		     | /*epsilon*/
 		     ;

Arg : TInt TId {char charnb[10];
						   	char arg[20]="arg";
							 	sprintf(charnb,"%d",sommet_arg-1);
							 	strcat(arg, charnb);
								int adrArg= rechercher_symbole(arg);
								if (adrArg==-1){
												ajouter_symbole(arg,1,prof);
							 					adrArg=rechercher_symbole(arg);
			 					}
								sommet_arg++;

								ajouter_symbole($2,1,prof);
								int adrId=rechercher_symbole($2);

								fprintf(out,"%d : LOAD R0 %d\n",ligne, adrArg);
								fprintf(out,"%d : STORE %d R0\n",ligne+1,adrId);
								increment_ligne(2);
								increment_instr(prof,2);

							}
    ;



// peut-être à factoriser avec BodyIf
Body :  ToBracket Instrs TcBracket {}
		;

BodyIf : ToBracket Instrs TcBracket {
										increment_ligne(1);
										increment_instr(prof,1);
										fermer_branche(prof);
										ajouter_branche("JMP",ligne-1,1,prof);
										fprintf(out,"XMP                   \n");
										}
		;

BodyWhile :  ToBracket Instrs TcBracket
			;

Instrs : /*epsilon*/
 		| Instr Instrs
    ;

Instr : Decl
        |If
        |While
        |Affect
        |Invoc
        ;

Invoc: TId ToParenthesis { //A chaque invocation, il va falloir manipuler la pile d'exécution en créant un espace mémoire pour l'adresse de retour
													// Il faut penser aux fonctions récursives

													//Sauvegarde de l'adresse de retour
													char charnb[10];
													char adrRet[20]="adrret";
													sprintf(charnb,"%d",sommet_adrRet);
													strcat(adrRet, charnb);
													ajouter_symbole(adrRet,1,prof);
													sommet_adrRet++;

													int adr_adrRet=rechercher_symbole(adrRet);

													//PEUT-ÊTRE FAUT-T-IL AJOUTER UN BRANCHEMENT--En fait ouais faut ajouter un branchement
													//car l'appel d'une fonction est comme l'appel d'un if
													fprintf(out,"%d : AFC R0 %d\n",ligne, ligne+3);//ICI PAS SUR DE QUELLE ADRESSE EST LA BONNE
													fprintf(out,"%d : STORE %d R0\n",ligne+1,adr_adrRet);

													increment_ligne(2);
													increment_instr(prof,2);
													}

			 Params TcParenthesis TSemicolon  { int indiceFonc=rechercher_fun($1);
				  																int adrDeb=get_adrDeb(indiceFonc);

																					fprintf(out,"%d : JMP %d\n",ligne, adrDeb); //-nb permet de remonter

																					//sauvegarde dans une variable temporaire le contenu retourné
																					char charnb[10];
																					char tmp[20]="tmp";
																					sprintf(charnb,"%d",sommet_tmp);
																					strcat(tmp, charnb);

																					int adrSymb= rechercher_symbole(tmp);
															 					 	if (adrSymb==-1){
															 					 			ajouter_symbole(tmp,1,prof);
															  					 		adrSymb=rechercher_symbole(tmp);
															 				 		}
															 						sommet_tmp++;

																					//je pense que ça c'est très mauvais et que ça marche pas en récursion
																					fprintf(out,"%d : LOAD R14 %d\n",ligne+1,adrSymb); //R14 est le registre où est enregistré le résultat de la fonction appelée

																					increment_ligne(2);
																					increment_instr(prof,2);

																					//on supprime les arguments enregistrés
																					int nbArg=get_nbArg(indiceFonc);
																					sommet_arg= sommet_arg -nbArg;

																					strcpy($$,tmp);;
			 																		}
      ;

Params : /*epsilon*/
        | Param
        | Param TComma ParamsNext
        ;

ParamsNext : Param
          | Param TComma ParamsNext
          ;

Param : Exp {//ajout d'un paramètre dans la pile des symboles
						char charnb[10];
				   	char arg[20]="arg";
					 	sprintf(charnb,"%d",sommet_arg);
					 	strcat(arg, charnb);
						//si déjà arg1 dans la pile on l'écrase, sinon on le crée
					 	int adrArg= rechercher_symbole(arg);
					 	if (adrArg==-1){
					 		ajouter_symbole(arg,1,prof);
 					 		adrArg=rechercher_symbole(arg);
				 			}
						sommet_arg++;
						//transfert de la valeur de Exp à Arg
						int adrTmp= rechercher_symbole($1);

						fprintf(out,"%d : LOAD R0 %d\n",ligne, adrTmp);
						fprintf(out,"%d : STORE %d R0\n",ligne+1,adrArg);
						increment_ligne(2);
						increment_instr(prof,2);

}
      ;

If : TIf ToParenthesis Exp {	int adrSymb= rechercher_symbole($3);
															fprintf(out,"%d : LOAD RZ %d\n",ligne, adrSymb);
															increment_ligne(1);
															increment_instr(prof,1);
															ajouter_branche("JMPZ", ligne,0,prof);
      												fprintf(out,"XMP            \n");
															increment_ligne(1);
															increment_instr(prof,1);
															prof++;
														}
		TcParenthesis BodyIf Else

Else : {fermer_branche(prof);
		prof--;}
    | TElse Body {fermer_branche(prof);
				  				prof--;}
    ;

While : TWhile {char charnb[10];   //on ajoute un premier branchement ici qui nous permettra de compter
																	// le nombre d'instruction y compris de la condition
			ajouter_branche("JMPZ",ligne,1,prof);
		}
		 ToParenthesis Exp {int adrSymb= rechercher_symbole($4);
													 fprintf(out,"%d : LOAD RZ %d\n",ligne, adrSymb);
													 fprintf(out,"XMP             \n");
													 //set_ligne_tab_branche(ligne+1,prof);
													 increment_ligne(2);
													 increment_instr(prof,2);
													 sommet_while++;
													 prof++;
													}
		TcParenthesis BodyWhile {int adrDebWhile=get_adr_tab_branche(prof-1);
														 printf("ligne : %d\n", ligne);
														 increment_instr(prof,1);
														 fermer_branche(prof);
														 fprintf(out,"%d : JMP %d\n",ligne, adrDebWhile);
											    	 increment_ligne(1);
														 prof --;
														 sommet_while--;
													 }

      ;


//toutes les expressions vont être traduites en variables temporaires
Exp : TId {//création nouvelle variable temporaire
					 char charnb[10];
					 char tmp[20]="tmp";
					 sprintf(charnb,"%d",sommet_tmp);
					 strcat(tmp, charnb);

					 int adrSymb= rechercher_symbole(tmp);
					 if (adrSymb==-1){
					 		ajouter_symbole(tmp,1,prof);
	 				    adrSymb=rechercher_symbole(tmp);
					 }
					 sommet_tmp++;

					 int adrId=rechercher_symbole($1);
					 //enregistrement du contenu du TId à l'adresse de la var tmp
					 fprintf(out,"%d : LOAD R0 %d\n",ligne, adrId);
			 		 fprintf(out,"%d : STORE %d R0\n",ligne+1,adrSymb);

					 increment_ligne(2);
					 increment_instr(prof,2);
				 	 strcpy($$,tmp);}

| TNumber {	//création nouvelle variable temporaire
					 char charnb[10];
				   char tmp[20]="tmp";
					 sprintf(charnb,"%d",sommet_tmp);
					 strcat(tmp, charnb);

					 int adrSymb= rechercher_symbole(tmp);
					 if (adrSymb==-1){
					 		ajouter_symbole(tmp,1,prof);
 					 		adrSymb=rechercher_symbole(tmp);
				 		}
						sommet_tmp++;
					 //enregistrement de TNumber à l'adresse de la var tmp
					 fprintf(out,"%d : AFC R0 %d\n",ligne, $1);
		 			 fprintf(out,"%d : STORE %d R0\n",ligne+1,adrSymb);
					 increment_ligne(2);
					 increment_instr(prof,2);

					 strcpy($$,tmp);}
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
			fprintf(out,"%d : LOAD R0 %d\n",ligne, adrExp);
			fprintf(out,"%d : STORE %d R0\n",ligne+1,adrId);
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
										fprintf(out,"%d : LOAD R0 %d\n",ligne, adrExp);
										fprintf(out,"%d : STORE %d R0\n",ligne+1,adrId);
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
	int lig=0;
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
		for (j=0;j<adr-lig;j++){//on se déplace jusqu'à la ligne à l'addresse enregistrée
			if(fgets(s,20, out)==NULL)
			     eof=1;
		}
		lig=adr;
		if (!eof){
			c=fgetc(out);
			if (c==EOF)
				eof=1;
			while (!eof && c!='X') { //correspond à une ligne laissée pour un jump
				//printf("caractere :%c\n", c);
				c=fgetc(out);
				if (c==EOF)
					eof=1;
				if (c=='\n')
					lig++;
			}
			fseek(out,-2*sizeof(char), SEEK_CUR);

			get_nom_tab_branche_with_indice(indice,nom);
			nb_instr=get_nb_instr_tab_branche_with_indice(indice);

			fprintf(out,"\n%d : %s %d", lig,nom, lig+nb_instr);
			fflush(out);
		}
	}

	printf("==============\n" );
	int i;
	for (i=0;i<3;i++){
		printf("Indice : %d\n" ,i);
		printf("adr: %d ; nb_instruct : %d\n", get_adr_tab_branche_with_indice(i),get_nb_instr_tab_branche_with_indice(i));
	}
	fclose(out);
	return 0;

}
