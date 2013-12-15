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
	string traducao, variavel, tipo;
};

struct variavel
{
    string nome, tipo;
};

map<string, struct variavel> tab_variaveis;
string declaracoes_temp = "";

int yylex(void);
void yyerror(string);
string getID(void);
string getTipo(string, string);


%}

%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING TK_SOMA_SUB TK_MULT_DIV
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_REAL TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_BOOL
%token TK_FIM TK_ERROR

%start S

%left TK_SOMA_SUB
%left TK_MULT_DIV


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

            | TIPO TK_ID ';'
            {
                tab_variaveis[$2.variavel] = {getID(), $1.traducao};
                $$.traducao = "\t" + $1.traducao + " " + tab_variaveis[$2.variavel].nome + ";\n";
            }
            
            | TIPO TK_ID '=' E ';'
            {
                tab_variaveis[$2.variavel] = {getID(), $1.traducao};
                $$.traducao = $4. traducao + "\t" + $1.traducao + " " + tab_variaveis[$2.variavel].nome + ";\n\t" + tab_variaveis[$2.variavel].nome + " = " + $4.variavel + ";\n";
            };

E 			: '('E')' 
			{
				$$.variavel = $2.variavel;
				$$.traducao = $2.traducao;
			}
			
			| E OPERADOR E
			{	
				$$.variavel = getID();
				
				string tipo = getTipo($1.tipo, $3.tipo);
				
				if($1.tipo != $3.tipo)
				{
					tipo = getTipo($1.tipo, $3.tipo);

					string temp_cast = getID();
					
					if($1.tipo != tipo)
					{
						$1.traducao += "\t" + tipo + " " + temp_cast + " = " + "(" + tipo + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
					}
					else
					{
						$3.traducao += "\t" + tipo + " " + temp_cast + " = " + "(" + tipo + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
					}
				}
				
				$$.tipo = tipo;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.tipo + " " + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			/*
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
			*/
			
			| VALOR
			{
				$$.variavel = getID();
				$$.traducao = "\t"+ $$.tipo + " " + $$.variavel + " = " + $1.traducao + ";\n";
			}
				
			/*
			| TK_NUM
			{
				$$.variavel = getID();
				$$.traducao = "\t"+ $$.tipo + " " + $$.variavel + " = " + $1.traducao + ";\n";
			}
			
			| TK_REAL
			{
				$$.variavel = getID();
				$$.traducao = "\t"+ $$.tipo + " " + $$.variavel + " = " + $1.traducao + ";\n";
			}
			*/
			
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
			
TIPO		: TK_TIPO_INT | TK_TIPO_REAL | TK_TIPO_CHAR | TK_TIPO_STRING | TK_TIPO_BOOL;

VALOR		: TK_NUM | TK_REAL | TK_CHAR | TK_STRING | TK_BOOL;

OPERADOR	: TK_SOMA_SUB | TK_MULT_DIV;

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

	//cout << "int " << ss.str() << endl;
	
	return ss.str();
}


//@TODO: Tabela de conversoes
string getTipo(string var1, string var2)
{
	if (var1 == "int" && var2 == "int")
		return "int";
	else
		return "float";
}
