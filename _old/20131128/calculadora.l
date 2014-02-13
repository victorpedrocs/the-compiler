%{
#include "calculadora.tab.h"
%}

DIGITO [0-9]
NUM {DIGITO}+
FLOAT {NUM}+("."{NUM}+)

%%

{FLOAT}	{	yylval = atof(yytext);
				printf("--- %f\n", (float)yylval);
				return FLOAT;
			}

{NUM}		{	yylval = atoi(yytext);
				return NUM;
			}




[+] 		{ return TK_SOMA; }
[-]		{ return TK_SUB; }
[*]		{ return TK_MULT; }
[/]		{ return TK_DIV; }
[(]		{ return TK_ABRE_PAR; }
[)]		{ return TK_FECHA_PAR; }
"\n" 		{ return TK_FIM; }
.		{ return TK_ERROR; }
%%
