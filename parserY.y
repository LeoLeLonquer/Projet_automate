%{
#include <stdio.h>
#include "tab_symb.h"
#define YYSTYPE double
//#include "lex.yy.c"
YYSTYPE yylval;
char *progname;
int yylex(void);
void yyerror(const char *s);

static int prof=0;

int expr_arith(char instr[16],int adr_retour,int adr1,int adr2){
  int res;
  printf("LOAD R0 %d\n" adr1);
  printf("LOAD R1 %d\n" adr2);
  if (strcmp(instr,"ADD")){res=adr1+adr2;printf ("ADD R0 R0 R1\n");}
  else if (strcmp(instr,"SUB")){res=adr1-adr2;printf ("SUB R0 R0 R1\n")}
  else if (strcmp(instr,"DIV")){res=adr1*adr2;printf ("DIV R0 R0 R1\n")}
  else if (strcmp(instr,"MUL")){res=adr1/adr2;printf ("MUL R0 R0 R1\n")}
  else if (strcmp(instr,"OR")){res=(adr1||adr2);printf ("OR R0 R0 R1\n")}
  else if (strcmp(instr,"AND")){res=(adr1&&adr2);printf ("AND R0 R0 R1\n")}
  else if (strcmp(instr,"EQU")){res=(adr1==adr2);printf ("EQU R0 R0 R1\n")}

  printf("STORE %d R0\n", adr_retour);
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

Param : E
      ;

If : TIf ToParenthesis E TcParenthesis Body
    | TIf ToParenthesis E TcParenthesis Body TElse Body
    ;

While : TWhile ToParenthesis E TcParenthesis Body
      ;

E : TId {$$=$1}
    | TNumber {$$=$1}
    | E TPlus E { $$ = expr_arith("ADD",$$,$1,$3)}
    | E TMinus E {  $$= expr_arith("SUB", $1 $3)}}
    | E TStar E {  $$= expr_arith("MUL", $1 $3)}}
    | E TSlash E {  $$= expr_arith("DIV", $1 $3)}}
    | E TOr E {  $$= expr_arith("OR", $1 $3)}}
    | E TAnd E {  $$= expr_arith("AND", $1 $3)}}
    | E TEquality E {  $$= expr_arith("EQU", $1 $3)}
    ;


Affect: TId TEqual E TSemicolon
      { int i =rechercher_symbole($1);
        if (i !=-1){
          yyerror("Variable non déclaré");
        }
        else {
          initialiser_symbole(i);
          printf("AFC R0 %d\n", $3);
          printf("STORE %d RO\n",$1);
          }
      }
      ;

Decl : TInt Decl1 DeclX TSemicolon ;

Decl1 : TId {ajouter_symbole({$1,0,prof})}
    	| TId TEqual E {ajouter_symbole({$1,1,prof})
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
