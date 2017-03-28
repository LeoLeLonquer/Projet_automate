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
  fprintf(out,"LOAD R0 %d\n", dollar1);
  fprintf(out,"LOAD R1 %d\n", dollar2);
  if (strcmp(instr,"ADD")==0){res=dollar1+dollar2; fprintf(out,"ADD R0 R0 R1\n");}
  else if (strcmp(instr,"SUB")==0){res=dollar1-dollar2;fprintf(out,"SUB R0 R0 R1\n");}
  else if (strcmp(instr,"DIV")==0){res=dollar1*dollar2;fprintf(out,"DIV R0 R0 R1\n");}
  else if (strcmp(instr,"MUL")==0){res=dollar1/dollar2;fprintf(out,"MUL R0 R0 R1\n");}
  else if (strcmp(instr,"OR")==0){res=(dollar1||dollar2);fprintf(out,"OR R0 R0 R1\n");}
  else if (strcmp(instr,"AND")==0){res=(dollar1&&dollar2);fprintf(out,"AND R0 R0 R1\n");}
  else if (strcmp(instr,"EQU")==0){res=(dollar1==dollar2);fprintf(out,"EQU R0 R0 R1\n");}
  fprintf(out,"STORE %d R0\n", dollardollar);
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

Body : ToBracket Instrs TcBracket { retirer_branche(prof);
									prof --;}
     ;

BodyElse :  ToBracket Instrs TcBracket {retirer_branche(prof);
										ajouter_branche(ligne,0,prof);
										fprintf(out,"\n");
									    increment_ligne(1);
		  								increment_instr(prof,1);	
										prof --;
										}
		;

BodyWhile :  ToBracket Instrs TcBracket {int nb=get_nb_instr_tab_branche(prof);
										retirer_branche(prof);
										fprintf(out,"JMP %d\n", ligne-nb); //-nb permet de remonter
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

If : TIf ToParenthesis Exp TcParenthesis Body {ajouter_branche(ligne,0,prof);
                                               fprintf(out,"\n");
												increment_ligne(1);
												increment_instr(prof,1);	                                              
												}
    | TIf ToParenthesis Exp TcParenthesis BodyElse TElse Body {ajouter_branche(ligne,0,prof);
                                                           fprintf(out,"\n");
															increment_ligne(1);
															increment_instr(prof,1);}
    ;

While : TWhile ToParenthesis Exp TcParenthesis BodyWhile {ajouter_branche(ligne,0,prof);
													 fprintf(out,"\n");
												    increment_ligne(1);
		  											increment_instr(prof,1);
													}
				
      ;

Exp : TId {$$=rechercher_symbole($1);} //TODO gération des TId
    | TNumber {$$=$1;}
    | Exp TPlus Exp { $$ = expr_arith("ADD",$$,$1,$3);}
    | Exp TMinus Exp {  $$= expr_arith("SUB", $$,$1, $3);}
    | Exp TStar Exp {  $$= expr_arith("MUL", $$,$1, $3);}
    | Exp TSlash Exp {  $$= expr_arith("DIV", $$,$1, $3);}
    | Exp TOr Exp {  $$= expr_arith("OR",$$, $1, $3);}
    | Exp TAnd Exp {  $$= expr_arith                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        