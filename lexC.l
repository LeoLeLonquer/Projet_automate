%{
#include <stdio.h>
%}

%%
main printf("Tmain");
int printf("Tint");
if printf("Tif");
while printf("Twhile");
const printf("Tconst");
\{ printf("T{");
\} printf("T}"); 
\( printf("T(");
\) printf("T)");
\[ printf("T[");
\] printf("T]");
\; printf("T;");
\= printf("T=");
\, printf("T,");
\+ printf("T+");
\- printf("T-");
\/ printf("T/");
\* printf("T*");
return printf("Treturn");
== printf("T==");
and printf("Tand");
or printf("Tor");
#include printf("Tinclude");
[0-9]+ printf("Tnumber");
[a-zA-Z][a-zA-Z0-9]* printf("Tid\n");
[ \t] ; /* ignore les blancs et tabulations */
%%
