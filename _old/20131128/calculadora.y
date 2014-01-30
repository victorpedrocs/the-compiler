%{
#include <iostream>
#include <string>
#include <sstream>
#include <stdlib.h>

#define YYSTYPE double

using namespace std;

int yylex(void);
void yyerror(string);

%}

%token NUM FLOAT DIGITO
%token TK_SOMA TK_FIM TK_ERROR TK_SUB TK_MULT TK_DIV TK_ABRE_PAR TK_FECHA_PAR

%start INICIO

%left TK_SOMA TK_SUB
%left TK_MULT TK_DIV 

%%

INICIO		: RESULTADO
		;
		
RESULTADO	: expr	TK_FIM { cout << "Resposta: " << $1 << endl; }
		;

expr		: TK_ABRE_PAR expr TK_FECHA_PAR { $$ = $2 }
		| expr TK_SOMA expr { $$ = $1 + $3; }
		| expr TK_SUB expr { $$ = $1 - $3; }
		| expr TK_MULT expr { $$ = $1 * $3; }
		| expr TK_DIV expr { $$ = $1 / $3; }
		| FLOAT { cout << $1 << endl;}
		| NUM
		| expr
		;

%%

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
