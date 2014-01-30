%{
#include <iostream>
#include <string>
#include <sstream>

#define YYSTYPE int

using namespace std;

int yylex(void);
void yyerror(string);
%}

%token NUM
%token TK_SOMA TK_FIM TK_ERROR

%start INICIO

%left TK_SOMA

%%

INICIO		: RESULTADO
		;
		
RESULTADO	: expr	TK_FIM { cout << "Resposta: " << $1 << endl; }
		;

expr		: expr TK_SOMA expr { $$ = $1 + $3; }
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
