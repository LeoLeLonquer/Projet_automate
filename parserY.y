%{
#include <stdio.h>
#include "tab_symb.h"
#include <stdlib.h>
#include <string.h>

char *progname;
int yylex(void);
void yyerror(const char *s);

static int ligne =0;
static int prof=0;

static FILE *out;

//int tmp[]; //tableau des variables temporaires: si tmp[1]=0 => tmp1 inutilisé, tmp[1]>0 => tmp1 utilisé

// La pile de variables temporaires s'empile dans le tableau des symboles
int sommet_tmp=0;// à utiliser lors de la gestion d'expression tel que a= 5+3+2 (sans parenthésage pour l'instant)

static debutWhile =0;

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

%left TPlus TMinus
%left TStar TSlash
%left TAnd TOr
%left TEquality

%start Prg    /*définit l'axiome de départ*/

%%
Prg: Fonction Prg
    |
    ;

//Fonctions :/* epsilon*/
//      |Fonction Fonctions
//			;



Fonction: TInt TId ToParenthesis Args TcParenthesis Body

        ;

//Main : TInt TMain ToParenthesis Args TcParenthesis Body ;


Args: /* epsilon*/
	| Arg ListeArgs
	;

ListeArgs: TComma Arg ListeArgs
		     | /*epsilon*/
 		     ;

Arg : TInt TId
    ;




Body :  ToBracket Instrs TcBracket // peut-être à factoriser avec BodyIf
		;

BodyIf : ToBracket Instrs TcBracket {
										increment_ligne(1);
										increment_instr(prof,1);
										retirer_branche(prof);
										ajouter_branche("JMP",ligne-1,1,prof);
										fprintf(out,"JMP                   \n");
										}
		;

BodyWhile :  ToBracket Instrs TcBracket {int nb=get_nb_instr_tab_branche(prof);
																				 retirer_branche(prof);
																				 fprintf(out,"%d : JMP %d\n",ligne, debutWhile); //-nb permet de remonter
									    							 	   increment_ligne(1);
		  																 	 increment_instr(prof,1);
																				 prof --;
																			 }
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

Invoc: TId ToParenthesis Params TcParenthesis TSemicolon
      ;

Params : /*epsilon*/
        | Param
        | Param TComma ParamsNext
        ;

ParamsNext : Param
          | Param TComma ParamsNext
          ;

Param : Exp
      ;

If : TIf ToParenthesis Exp {	int adrSymb= rechercher_symbole($3);
															fprintf(out,"%d : LOAD RZ %d\n",ligne, adrSymb);
															increment_ligne(1);
															increment_instr(prof,1);
															ajouter_branche("JMPZ", ligne,0,prof);
      												fprintf(out,"JMP            \n");
															increment_ligne(1);
															increment_instr(prof,1);
															prof++;
														}
		TcParenthesis BodyIf Else

Else : {retirer_branche(prof);
		prof--;}
    | TElse Body {retirer_branche(prof);
				  				prof--;}
    ;

While : TWhile {debutWhile=ligne;}
				ToParenthesis Exp {int adrSymb= rechercher_symbole($4);
													 fprintf(out,"%d : LOAD RZ %d\n",ligne, adrSymb);
													 increment_ligne(1);
													 increment_instr(prof,1);
													 ajouter_branche("JMPZ", ligne,1,prof);
		        							 fprintf(out,"JMP             \n");
			    								 increment_ligne(1);
													 increment_instr(prof,1);
													 prof++;
													}
				TcParenthesis BodyWhile

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
	| TId TEqual Exp { int adrId =rechercher_symbole($1);
											if (adrId !=-1){
												yyerror("Variable déjà déclarée auparavant");
											}
											else {
												ajouter_symbole($1,1,prof);
												int adrId=rechercher_symbole($1);
												int adrExp= rechercher_symbole($3);
												fprintf(out,"%d : LOAD R0 %d\n",ligne, adrExp);
												fprintf(out,"%d : STORE %d R0\n",ligne+1,adrId);
												increment_ligne(2);
												increment_instr(prof,2);

												sommet_tmp--; //plus besoin de la var tmp Exp
												}
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
	int indice;
	int nb_instr;
	int adr;
	char *nom=(char *)malloc(20*sizeof(char));
	char c;
	int eof=0;
 	char * s=malloc(20000+1);
	rewind(out);

	while (fgets(s,20, out)!=NULL){
				printf("Je suis dans le 1er While (fin)\n") ;
				//printf("Ligne courante : %s ", s);
		eof=0;
		while(s[0]!='J' && !eof){
				lig++;
				if (fgets(s,20, out)==NULL)
					eof=1;
			 printf("Je suis dans le 2e While (fin) ligne %d\n", lig) ;
		}
		printf("Coucou1\n");
		if (!eof) {
			c=fgetc(out);
			while (c!='J') {
				//printf("caractere :%c\n", c);
				c=fgetc(out);
				fseek(out,-2*sizeof(char), SEEK_CUR);
			}
			printf("Coucou2\n");

			int i;
			for (i=0;i<12;i++){
				printf("Indice : %d\n" ,i);
				printf("adr: %d ; nb_instruct : %d\n", get_adr_tab_ended(i),get_nb_instr_tab_ended(i));
			}

			indice=rechercher_element_tab_ended(lig);
			printf("Coucou42\n");
			get_nom_tab_ended(indice,nom);
			adr= get_adr_tab_ended(indice);
			nb_instr=get_nb_instr_tab_ended(indice);

			fprintf(out,"\n%d : %s %d", adr,nom, adr+nb_instr);

			fflush(out);
			printf("Coucou3\n");

		}
	}
	printf("==============\n" );
	int i;
	for (i=0;i<3;i++){
		printf("Indice : %d\n" ,i);
		printf("adr: %d ; nb_instruct : %d\n", get_adr_tab_ended(i),get_nb_instr_tab_ended(i));
	}
	fclose(out);
	return 0;

}
