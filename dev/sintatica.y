%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <utility>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string traducao;
	string variavel;
};
struct variavel
{
    string nome, tipo;
};

map<string, struct variavel> tab_variaveis;

int yylex(void);
void yyerror(string);
string getID(void);


%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

%left '+''-'
%left '*''/'


%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador C'*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';'

            | TK_TIPO_INT TK_ID ';'
            {
                string nome_temp = getID();
                //tab_variaveis.insert(pair<string, struct variavel>($2.variavel, {nome_temp, $1.traducao}));
                tab_variaveis[$2.variavel] = {nome_temp, $1.traducao};
                $$.traducao = "\t" + $1.traducao + " " + nome_temp + ";\n";
            };

E 			: '('E')' 
			{
				$$.variavel = $2.variavel;
				$$.traducao = $2.traducao;
			}
			
			| E '+' E
			{	
				$$.variavel = getID();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " + " + $3.variavel + ";\n";
			}
			
			| E '-' E
			{	
				$$.variavel = getID();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " - " + $3.variavel + ";\n";
			}
			
			| E '*' E
			{	
				$$.variavel = getID();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " * " + $3.variavel + ";\n";
			}
			
			| E '/' E
			{	
				$$.variavel = getID();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " / " + $3.variavel + ";\n";
			}
			
			| TK_NUM
			{
				$$.variavel = getID();
				$$.traducao = "\t"+ $$.variavel + " = " + $1.traducao + ";\n";
			}
			
			| TK_ID '=' E
			{

				$$.traducao = $3.traducao + "\t" + tab_variaveis[$1.variavel].nome + " = " + $3.variavel + ";\n";
			}
			
			| TK_ID
			{
				$$.traducao = "";
				$$.variavel = tab_variaveis[$1.variavel].nome;
			}
			;

%%

#include "lex.yy.c"

int yyparse();

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

string getID()
{
	static int i = 0;

	stringstream ss;
	ss << "temp" << i++;
	
	return ss.str();
}
