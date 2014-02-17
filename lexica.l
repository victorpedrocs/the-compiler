%{

#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z]
CARACTER_ESP [?!*@#$:%&=\\_-]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID _?({LETRA}|{NUM}|_)*
STRING "\""({LETRA}|{NUM}|{CARACTER_ESP}|{ESPACO})*"\""
COMENTARIO ("//"[^\n]*)|("/*"[^"*/"]*"*/")

%%

"\n"		{}

{DELIM} 	{}

"continue"	{return TK_CONTINUE;}
"break"		{return TK_BREAK;}
"switch"	{return TK_SWITCH;}
"case"		{return TK_CASE;}
"return"    {return TK_RETURN;}
":"			{return TK_DOISPONTOS;}
"print"	{ return TK_PRINT; }
"scan"	{ return TK_SCAN; }


"if"		{return TK_IF;}
"else"		{return TK_ELSE;}
"while"		{return TK_WHILE;}
"do"		{return TK_DO;}
"for"		{return TK_FOR;}
"void"		{yylval.tipo = yytext; return TK_TIPO_VOID;}
"int"		{yylval.tipo = yytext; return TK_TIPO_INT;}
"float"		{yylval.tipo = yytext; return TK_TIPO_REAL;}
"char"		{yylval.tipo = yytext; return TK_TIPO_CHAR;}
"string"	{yylval.tipo = "string"; return TK_TIPO_STRING;}
"boolean"	{yylval.tipo = "unsigned short int"; return TK_TIPO_INT;}

(\[{NUM}\])+	{ yylval.traducao = yytext; return TK_TAM_VET; }

[(){}[\];,=]	{ return *yytext; }


"++"	{ yylval.traducao = yytext; return TK_MM;}
"--"	{ yylval.traducao = yytext; return TK_MM;}

[+\-]	{ yylval.traducao = yytext; return TK_SOMA_SUB; }
[*/]	{ yylval.traducao = yytext; return TK_MULT_DIV; }

">="	{ yylval.traducao = yytext; return TK_OP_REL; }
">"		{ yylval.traducao = yytext; return TK_OP_REL; }
"<="	{ yylval.traducao = yytext; return TK_OP_REL; }
"<"		{ yylval.traducao = yytext; return TK_OP_REL; }
"=="	{ yylval.traducao = yytext; return TK_OP_IGUALDADE; }
"!="	{ yylval.traducao = yytext; return TK_OP_IGUALDADE; }

"&&"	{ yylval.traducao = yytext; return TK_OP_LOG; }
"||"	{ yylval.traducao = yytext; return TK_OP_LOG; }
"!"		{ yylval.traducao = yytext; return TK_NEG; }

{NUM}		{ yylval.traducao = yytext; yylval.tipo = "int"; return TK_NUM; }
{ID}		{ yylval.variavel = yytext; return TK_ID; }
{REAL}		{ yylval.traducao = yytext; yylval.tipo = "float"; return TK_REAL; }
{CHAR}		{ yylval.traducao = yytext; yylval.tipo = "char"; return TK_CHAR; }
{STRING} 	{ yylval.traducao = yytext; yylval.tipo = "string";return TK_STRING;}
{COMENTARIO}	{}

.		{ *yytext; }

%%
