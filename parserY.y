%{
#include <stdio.h>
#define YYSTYPE double
//#include "lex.yy.c"
YYSTYPE yylval;
char *progname;
int yylex(void);
void yyerror(const char *s);
%}

%error-verbose
%token TMain TInt TIf TWhile TConst ToBracket TcBracket
%token ToParenthesis TcParenthesis ToCrochet TcCrochet
%token TSemicolon TEqual TComma TPlus TMinus TSlash
%token TStar TReturn TEquality TAnd TOr TInclude
%token TNumber TId TElse

%left TPlus TMinus
%left TStar TSlash
%left TAnd TOr
%left TEquality


/* %type <nb> TInt */
%start Prg    /*définit l'axiome de départ*/

%%
Prg: Fonctions Main {printf("Hello\n");};
    | /* epsilon */ ;

Main : TInt TMain ToParenthesis Args TcParenthesis Body ;

Fonctions : Fonction Fonctions
			|/* epsilon*/
			;

Fonction: TInt TId ToParenthesis Args TcParenthesis Body ;

Args: /* epsilon*/
	| Arg ListeArgs
	;

ListeArgs: TComma Arg ListeArgs
		 | /*epsilon*/
 		 ;

Arg : TInt TId
    ;

Body : ToBracket Instrs TcBracket;

Instrs : /*epsilon*/
 		| Instr Instrs ;

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

E : TId
    | TNumber
    | E TPlus E
    | E TMinus E
    | E TStar E
    | E TSlash E
    | E TOr E
    | E TAnd E
    | E TEquality E
    ;


Affect: TId TEqual E TSemicolon ;

Decl : TInt Decl1 DeclX TSemicolon ;

Decl1 : TId
    	| TId TEqual E
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
