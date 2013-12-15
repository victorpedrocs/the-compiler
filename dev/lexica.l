%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{yylval.traducao = yytext; return TK_TIPO_INT;}
"float"		{yylval.traducao = yytext; return TK_TIPO_REAL;}
"char"		{yylval.traducao = yytext; return TK_TIPO_CHAR;}
"string"	{yylval.traducao = yytext; return TK_TIPO_STRING;}
"boolean"	{yylval.traducao = yytext; return TK_TIPO_BOOL;}

[(){}[\];,=]	{ return *yytext; }

[+\-]	{ yylval.traducao = yytext; return TK_SOMA_SUB; }
[*/]	{ yylval.traducao = yytext; return TK_MULT_DIV; }

{ID}		{ yylval.variavel = yytext; return TK_ID; }
{NUM}		{ yylval.traducao = yytext; yylval.tipo = "int"; return TK_NUM; }
{REAL}		{ yylval.traducao = yytext; yylval.tipo = "float"; return TK_REAL; }
{CHAR}		{ yylval.traducao = yytext; yylval.tipo = "char"; return TK_CHAR; }

.		{ *yytext; }

%%
