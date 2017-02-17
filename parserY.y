%{
#include <stdio.h>
%}

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
/*%start start     je sais pas ce que ça fait*/

%%
Prg: Fonction Prg ;
    | /* epsilon */ ;

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
