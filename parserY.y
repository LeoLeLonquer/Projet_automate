%{
#include <stdio.h>
#include "tab_symb.h"
#include <stdlib.h>

char *progname;
int yylex(void);
void yyerror(const char *s);

static int ligne =0;
static int prof=0;

static FILE *out;

int increment_ligne(int x){
	ligne=ligne+x;
}


int expr_arith(char instr[16],int dollardollar,int dollar1,int dollar2){
  int res;
  fprintf(out,"%d : LOAD R0 %d\n",ligne, dollar1);
  fprintf(out,"%d : LOAD R1 %d\n",ligne+1, dollar2);
  if (strcmp(instr,"ADD")==0){res=dollar1+dollar2; fprintf(out,"%d : ADD R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"SUB")==0){res=dollar1-dollar2;fprintf(out,"%d : SUB R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"DIV")==0){res=dollar1*dollar2;fprintf(out,"%d : DIV R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"MUL")==0){res=dollar1/dollar2;fprintf(out,"%d : MUL R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"OR")==0){res=(dollar1||dollar2);fprintf(out,"%d : OR R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"AND")==0){res=(dollar1&&dollar2);fprintf(out,"%d : AND R0 R0 R1\n",ligne+2);}
  else if (strcmp(instr,"EQU")==0){res=(dollar1==dollar2);fprintf(out,"%d : EQU R0 R0 R1\n",ligne+2);}
  fprintf(out,"%d : STORE %d R0\n", ligne+3,dollardollar);
  increment_ligne(4);
  increment_instr(prof,4);
  return  res;
}

%}

%error-verbose

%union
{
    int number;
    char *string;
}

%token TMain TInt TIf TWhile TConst ToBracket TcBracket
%token ToParenthesis TcParenthesis ToCrochet TcCrochet
%token TSemicolon TEqual TComma TPlus TMinus TSlash
%token TStar TReturn TEquality TAnd TOr TInclude TElse

%token <number> TNumber
%token <string> TId

%type <number> Exp

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

BodyIf : ToBracket Instrs TcBracket {retirer_branche(prof);
										ajouter_branche(ligne,1,prof);
										fprintf(out,"JMP                   \n");
									  	increment_ligne(1);
		  								increment_instr(prof,1);
										//prof --;
										}
		;

BodyWhile :  ToBracket Instrs TcBracket {int nb=get_nb_instr_tab_branche(prof);
										retirer_branche(prof);
										fprintf(out,"%d : JMP %d\n",ligne, ligne-nb); //-nb permet de remonter
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

If : TIf {	printf("Voici la ligne : %d",ligne);
			ajouter_branche(ligne,1,prof);
            fprintf(out,"JMP            \n");
			increment_ligne(1);
			increment_instr(prof,1);
			prof++;
		}
 	ToParenthesis Exp TcParenthesis BodyIf Else

Else : {retirer_branche(prof);
		prof--;}
    | TElse Body {retirer_branche(prof);
				  prof--;}
    ;

While : TWhile {ajouter_branche(ligne,1,prof);
		        fprintf(out,"JMP             \n");
			    increment_ligne(1);
				increment_instr(prof,1);
				prof++;
				}
		ToParenthesis Exp TcParenthesis BodyWhile

      ;

Exp : TId {$$=rechercher_symbole($1);} //TODO gération des TId
| TNumber {$$=$1;}
| Exp TPlus Exp { $$ = expr_arith("ADD",$$,$1,$3);}
| Exp TMinus Exp {  $$= expr_arith("SUB", $$,$1, $3);}
| Exp TStar Exp {  $$= expr_arith("MUL", $$,$1, $3);}
| Exp TSlash Exp {  $$= expr_arith("DIV", $$,$1, $3);}
| Exp TOr Exp {  $$= expr_arith("OR",$$, $1, $3);}
| Exp TAnd Exp {  $$= expr_arith("AND",$$, $1, $3);}
| Exp TEquality Exp {  $$= expr_arith("EQU",$$, $1, $3);}
;
Affect: TId TEqual Exp TSemicolon
	{ int i =rechercher_symbole($1);
		if (i !=-1){
			yyerror("Variable non déclaré");
		}
		else {
			initialiser_symbole(i);
			fprintf(out,"%d : AFC R0 %d\n",ligne, $3);
			/*fprintf(out,"%d : STORE %d RO\n",ligne+1,$1);*/
			increment_ligne(1);
			increment_instr(prof,1);
			}
	}
	;
Decl : TInt Decl1 DeclX TSemicolon ;
Decl1 : TId {ajouter_symbole($1,0,prof);}
	| TId TEqual Exp {ajouter_symbole($1,1,prof);
										fprintf(out,"%d : AFC R0 %d\n",ligne, $3);
									/*  fprintf(out,"%d : STORE %d RO\n",ligne+1,$1);*/
									increment_ligne(1);
									increment_instr(prof,1);	}
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
	int flag=0;
 	char * s=malloc(2000+1);
	printf("Ready 1\n") ;
	//fgets(s,20, out);
	//printf("%s", s);
	rewind(out);
	//fseek(out,0,0);
	printf("Ready 2\n") ;
	//fgets(s,2000, out);
	//printf("%s", s);



	while (fgets(s,20, out)!=NULL){
				printf("Je suis dans le 1er While (fin)\n") ;
		flag=0;
		while(s[0]!='J' && !flag){
				lig++;
				if (fgets(s,20, out)==NULL)
					flag=1;
			printf("Je suis dans le 2e While (fin) ligne %d\n", lig) ;
		}
		if (!flag) {
			fseek(out,-sizeof("JMP            \n") , SEEK_CUR);
			printf("sortie du 2e while, lig = %d\n", lig) ;
			indice=rechercher_element_tab_ended(lig); //*************************** erreur ici?
			printf("indice ok\n") ;
			adr= get_adr_tab_ended(indice);
			printf("voici adr : %d\n", adr);
			printf("adr ok\n") ;
			nb_instr=get_nb_instr_tab_ended(indice);
			printf("nb_instr ok\n") ;
			//fprintf(out,"\nYO\n");
			fprintf(out,"\n%d : JMP %d",adr, adr+nb_instr);
			printf("JUMP FAIT!! \n") ;
			fflush(out);
		}
	}
	fclose(out);
	return 0;

}
