%{
#include <stdio.h>
%}



%%
"main"  {return TMain ;}
"int"  {return TInt ;}
"if"  {return TIf ;}
"else" {return TElse ;}
"while"  {return TWhile ;}
"const"  {return TConst ;}
"{"  {return ToBracket  ;}
"}"  {return TcBracket  ;}
"("  {return ToParenthesis ;}
")"  {return TcParenthesis ;}
"["  {return ToCrochet ;}
"]"  {return TcCrochet ;}
";"  {return TSemicolon ;}
"="  {return TEqual ;}
","  {return TComma ;}
"+"  {return TPlus ;}
"-"  {return TMinus ;}
"/"  {return TSlash ;}
"*"  {return TStar ;}
"return"  {return TReturn ;}
"=="  {return TEquality ;}
"and"  {return TAnd ;}
"or"  {return TOr ;}
"#include"  {return TInclude ;}
[0-9]+  {return TNumber ;}
[a-zA-Z][a-zA-Z0-9]*  {return TId ;}
[ \t]  {;} ; /* ignore les blancs et tabulations */
%%
