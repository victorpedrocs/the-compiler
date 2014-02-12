%{

#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z]
CARACTER_ESP [?!*@#$:%&=_-]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID _?({LETRA}|{NUM}|_)*
STRING "\""({LETRA}|{NUM}|{CARACTER_ESP}|{ESPACO})*"\""

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}
"continue"	{return TK_CONTINUE;}
"break"		{return TK_BREAK;}
"switch"	{return TK_SWITCH;}
"case"		{return TK_CASE;}
"return"    {return TK_RETURN;}
":"			{return TK_DOISPONTOS;}


"if"		{return TK_IF;}
"else"		{return TK_ELSE;}
"while"		{return TK_WHILE;}
"do"		{return TK_DO;}
"for"		{return TK_FOR;}
"int"		{yylval.tipo = yytext; return TK_TIPO_INT;}
"float"		{yylval.tipo = yytext; return TK_TIPO_REAL;}
"char"		{yylval.tipo = yytext; return TK_TIPO_CHAR;}
"string"	{yylval.tipo = "string"; return TK_TIPO_STRING;}
"boolean"	{yylval.tipo = "unsigned short int"; return TK_TIPO_INT;}

[(){}[\];,=]	{ return *yytext; }


"++"	{ yylval.traducao = yytext; return TK_MM;}
"--"	{ yylval.traducao = yytext; return TK_MM;}

[+\-]	{ yylval.traducao = yytext; return TK_SOMA_SUB; }
[*/]	{ yylval.traducao = yytext; return TK_MULT_DIV; }

">="	{ yylval.traducao = yytext; return TK_OP_REL; }
">"		{ yylval.traducao = yytext; return TK_OP_REL; }
"<="	{ yylval.traducao = yytext; return TK_OP_REL; }
"<"		{ yylval.traducao = yytext; return TK_OP_REL; }
"=="	{ yylval.traducao = yytext; return TK_OP_REL; }
"!="	{ yylval.traducao = yytext; return TK_OP_REL; }

"&&"	{ yylval.traducao = yytext; return TK_OP_LOG; }
"||"	{ yylval.traducao = yytext; return TK_OP_LOG; }
"!"		{ yylval.traducao = yytext; return TK_NEG; }

"print"	{ return TK_PRINT; }
"scan"	{ return TK_SCAN; }

{NUM}		{ yylval.traducao = yytext; yylval.tipo = "int"; return TK_NUM; }
{ID}		{ yylval.variavel = yytext; return TK_ID; }
{REAL}		{ yylval.traducao = yytext; yylval.tipo = "float"; return TK_REAL; }
{CHAR}		{ yylval.traducao = yytext; yylval.tipo = "char"; return TK_CHAR; }
{STRING} 	{ yylval.traducao = yytext; yylval.tipo = "string";return TK_STRING;}

.		{ *yytext; }

%%
