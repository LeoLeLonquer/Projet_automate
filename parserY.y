%{
#include <stdio.h>
#include "tab_symb.h"

char *progname;
int yylex(void);
void yyerror(const char *s);

static int prof=0;

int expr_arith(char instr[16],int dollardollar,int dollar1,int dollar2){
  int res;
  printf("LOAD R0 %d\n", dollar1);
  printf("LOAD R1 %d\n", dollar2);
  if (strcmp(instr,"ADD")==0){res=dollar1+dollar2;printf ("ADD R0 R0 R1\n");}
  else if (strcmp(instr,"SUB")==0){res=dollar1-dollar2;printf ("SUB R0 R0 R1\n");}
  else if (strcmp(instr,"DIV")==0){res=dollar1*dollar2;printf ("DIV R0 R0 R1\n");}
  else if (strcmp(instr,"MUL")==0){res=dollar1/dollar2;printf ("MUL R0 R0 R1\n");}
  else if (strcmp(instr,"OR")==0){res=(dollar1||dollar2);printf ("OR R0 R0 R1\n");}
  else if (strcmp(instr,"AND")==0){res=(dollar1&&dollar2);printf ("AND R0 R0 R1\n");}
  else if (strcmp(instr,"EQU")==0){res=(dollar1==dollar2);printf ("EQU R0 R0 R1\n");}
  printf("STORE %d R0\n", dollardollar);
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

Body : ToBracket Instrs TcBracket
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

If : TIf ToParenthesis Exp TcParenthesis Body {ajouter_branche();
                                               printf("\n");
                                              }
    | TIf ToParenthesis Exp TcParenthesis Body TElse Body {ajouter_instr();
                                                           printf("\n");}
    ;

While : TWhile ToParenthesis Exp TcParenthesis Body
      ;

Exp : TId {$$=(int)$1;} //TODO gération des TId
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
          printf("AFC R0 %d\n", $3);
          /*printf("STORE %d RO\n",$1);*/
          }
      }
      ;

Decl : TInt Decl1 DeclX TSemicolon ;

Decl1 : TId {ajouter_symbole($1,0,prof);}
    	| TId TEqual Exp {ajouter_symbole($1,1,prof);
                        printf("AFC R0 %d\n", $3);
                      /*  printf("STORE %d RO\n",$1);*/}
    	;

DeclX : /*epsilon*/
  		| TComma Decl1 DeclX
  		;
%%
void yyerror(const char *s ){
  fprintf(stderr,"%s\n",s);
}
int main(void){
  printf("Compilator");
  yyparse();
  return 0;
}
