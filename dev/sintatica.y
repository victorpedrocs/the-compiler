%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <utility>
#include <list>

#define YYSTYPE atributos

using namespace std;

typedef map<string, struct variavel>::iterator mapa_it;
typedef map<string, struct variavel> mapa;

struct atributos
{
	string traducao, variavel, tipo;
	int tamanho;
};

struct variavel
{
    string nome, tipo;
    int tamanho;
};

int yylex(void);
void yyerror(string);
string getID(void);
string getTipo(string, string, string);
string getTipoCast(string var1, string var2);
map<string, string> cria_tabela_tipos();
void imprimeDeclaracoes();

mapa* tab_variaveis = new mapa();
map<string, string> tab_tipos = cria_tabela_tipos();

list<mapa*> pilhaDeMapas;

pilhaDeMapas.push_front(tab_variaveis);

%}

%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING TK_SOMA_SUB TK_MULT_DIV TK_OP_REL TK_OP_LOG
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_REAL TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_BOOL
%token TK_FIM TK_ERROR

%start S

%left TK_SOMA_SUB TK_OP_REL 
%left TK_MULT_DIV
%left TK_OP_LOG


%%


S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador C'*/\n" << "#include<stdio.h>\n#include<string.h>\nint main(void)\n{\n" <<endl;
				imprimeDeclaracoes();
				cout << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: ABRE_BLOCO COMANDOS '}'
			{
				$$.traducao = $2.traducao;
				//desempilha mapa
			}
			;
			
ABRE_BLOCO	: '{'
			{
				
			}
			;

/*
BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;
*/

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
                (*tab_variaveis)[$2.variavel] = {getID(), $1.tipo};
                $$.traducao = "";
            }
            
            | TK_ID '=' E ';'
			{
				if($$.tipo == "string")
					$$.traducao = $3.traducao + "\tstrcpy(" + (*tab_variaveis)[$1.variavel].nome + ", " + $3.variavel + ");\n";
				else
					$$.traducao = $3.traducao + "\t" + (*tab_variaveis)[$1.variavel].nome + " = " + $3.variavel + ";\n";
				
				(*tab_variaveis)[$1.variavel].tamanho = $3.tamanho;
			}
			
            | TIPO TK_ID '=' E ';'
            {
            
//            	cout << "O tamanho de E é: " << (*tab_variaveis)[$4.variavel].tamanho << endl;
                (*tab_variaveis)[$2.variavel] = {getID(), $1.tipo, $4.tamanho};
                
                /*
                // <casting>
                if($1.tipo != $4.tipo)
                {
                	string temp_cast = getID();
                	$4.traducao += "\t" + $1.tipo + " " + temp_cast + " = " + "(" + $1.tipo + ")" + $4.variavel + ";\n";
                	$4.variavel = temp_cast;
                	$$.traducao = $4.traducao + "\t" + $1.tipo + " " + (*tab_variaveis)[$2.variavel].nome + " = " + $4.variavel + ";\n";
                }
                // </casting>
                else
                */	
                if($2.tipo == "string")
	                $$.traducao = $4.traducao + "\tstrcpy(" + (*tab_variaveis)[$2.variavel].nome + ", " + $4.variavel + ");\n";                	
	            else
	                $$.traducao = $4.traducao + "\t" + (*tab_variaveis)[$2.variavel].nome + " = " + $4.variavel + ";\n";
               
                (*tab_variaveis)[$2.variavel].tamanho = $4.tamanho;

            };

E 			: '('E')' 
			{
				$$.variavel = $2.variavel;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
			}
			
			| E TK_SOMA_SUB E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				
				
				/*<casting>
				if($1.tipo != $3.tipo)
				{
					string temp_cast = getID();
					
					if($1.tipo != getTipoCast($1.tipo, $3.tipo))
					{
						$1.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				</casting> */
				
				if(tipo_retorno == "string")
				{
					$$.traducao = $1.traducao + $3.traducao + "\tstrcpy(" + $$.variavel + ", " + $1.variavel + ");\n\tstrcat(" + $$.variavel + ", " + $3.variavel + ");\n"; 
					$$.tamanho = $1.tamanho + $3.tamanho;
					(*tab_variaveis)[$$.variavel] = {$$.variavel, tipo_retorno, $$.tamanho};
					
				}

				else
				{
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";	
					(*tab_variaveis)[$$.variavel] = {$$.variavel, tipo_retorno};
				}	
				
				$$.tipo = tipo_retorno;
				
			}
			
			| E TK_MULT_DIV E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*tab_variaveis)[$$.variavel] = {$$.variavel, tipo_retorno};
				
				//<casting>
				if($1.tipo != $3.tipo)
				{
					string temp_cast = getID();
					
					if($1.tipo != getTipoCast($1.tipo, $3.tipo))
					{
						$1.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				//</casting>
				$$.tipo = tipo_retorno;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			| E TK_OP_LOG E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*tab_variaveis)[$$.variavel] = {$$.variavel, tipo_retorno};
				
				//<casting>
				if($1.tipo != $3.tipo)
				{
					string temp_cast = getID();
					
					if($1.tipo != getTipoCast($1.tipo, $3.tipo))
					{
						$1.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				//</casting>
				$$.tipo = tipo_retorno;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			| VALOR
			{	
				$$.variavel = getID();
				(*tab_variaveis)[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			
			| TK_STRING
			{	
				$$.variavel = getID();
				$$.tamanho = (int) $1.traducao.length()-2;
				(*tab_variaveis)[$$.variavel] = {$$.variavel, $1.tipo, $$.tamanho}; // -2 para descontar as aspas
				$$.traducao = "\tstrcpy(" + $$.variavel + ", " + $1.traducao + ");\n";
			}
			
			| E TK_OP_REL E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*tab_variaveis)[$$.variavel] = {$$.variavel, tipo_retorno};
				
				//<casting>
				if($1.tipo != $3.tipo)
				{
					string temp_cast = getID();
					
					if($1.tipo != getTipoCast($1.tipo, $3.tipo))
					{
						$1.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + tipo_retorno + " " + temp_cast + " = " + "(" + getTipoCast($1.tipo, $3.tipo) + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				//</casting>
				$$.tipo = tipo_retorno;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			| TK_ID
			{
				$$.traducao = "";
				$$.variavel = (*tab_variaveis)[$1.variavel].nome;
				$$.tamanho = (*tab_variaveis)[$1.variavel].tamanho;
			}
			;
			
TIPO		: TK_TIPO_INT | TK_TIPO_REAL | TK_TIPO_CHAR | TK_TIPO_STRING | TK_TIPO_BOOL;

VALOR		: TK_NUM | TK_REAL | TK_CHAR;

//OPERADOR	: TK_OP_REL | TK_OP_LOG;


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
	ss << "$temp" << i++;
	
	return ss.str();
}


string getTipo(string var1, string op, string var2)
{
    string tipo_retorno = "";
    
    tipo_retorno = tab_tipos[var1+op+var2];
    if(tipo_retorno != "")    
		return tipo_retorno;
		
	tipo_retorno = tab_tipos[var2+op+var1];
	if(tipo_retorno != "")
		return tipo_retorno;
	
	perror("ERRO: Tipos incompativeis");
	exit(EXIT_FAILURE);
}

//não está funcionando mais depois da string.
string getTipoCast(string var1, string var2)
{

	if(var1 == "float" || var2 == "float")
		return "float";
		
	else if (var1 == "string" || var2 == "string")	
		return "string";
		
	else return "int";
	
}

map<string, string> cria_tabela_tipos()
{
    map<string, string> tabela_tipos;
    tabela_tipos["int+int"] = "int";
    tabela_tipos["int+float"] = "float";
    tabela_tipos["int+string"] = "string";
    tabela_tipos["int+char"] = "char";
    tabela_tipos["float+float"] = "float";
    tabela_tipos["float+string"] = "string";
    tabela_tipos["char+char"] = "string";
    tabela_tipos["char+string"] = "string";
    tabela_tipos["float+string"] = "string";
    tabela_tipos["string+string"] = "string";
    
    tabela_tipos["int-int"] = "int";
    tabela_tipos["int-float"] = "float";
    tabela_tipos["int-char"] = "char";
    tabela_tipos["float-float"] = "float";
    
    tabela_tipos["int*int"] = "int";
    tabela_tipos["int*float"] = "float";
    tabela_tipos["float*float"] = "float";
    
    tabela_tipos["int/int"] = "int";
    tabela_tipos["int/float"] = "float";
    tabela_tipos["float/float"] = "float";
      
    tabela_tipos["int>int"] = "int";
    tabela_tipos["float>float"] = "int";
    tabela_tipos["float>int"] = "int";
    tabela_tipos["char>char"] = "int";    
	tabela_tipos["string>string"] = "int"; //@ TODO

    tabela_tipos["int>=int"] = "int";
    tabela_tipos["float>=float"] = "int";
    tabela_tipos["float>=int"] = "int";
    tabela_tipos["char>=char"] = "int";
    tabela_tipos["string>=string"] = "int"; //@ TODO
    
    tabela_tipos["int<int"] = "int";
    tabela_tipos["float<float"] = "int";
    tabela_tipos["float<int"] = "int";
    tabela_tipos["char<char"] = "int";
    tabela_tipos["string<string"] = "int";
    
    tabela_tipos["int<=int"] = "int";
    tabela_tipos["float<=float"] = "int";
    tabela_tipos["float<=int"] = "int";
    tabela_tipos["char<=char"] = "int";
    tabela_tipos["string<=string"] = "int"; //@ TODO
    
    tabela_tipos["int==int"] = "int";
    tabela_tipos["float==float"] = "int";
    tabela_tipos["float==int"] = "int";
    tabela_tipos["char==char"] = "int";
    tabela_tipos["string==string"] = "int";
    
    tabela_tipos["int!=int"] = "int";
    tabela_tipos["float!=float"] = "int";
    tabela_tipos["float!=int"] = "int";
    tabela_tipos["char!=char"] = "int";
    tabela_tipos["string!=string"] = "int";
    
    tabela_tipos["int&&int"] = "int";
    tabela_tipos["int||int"] = "int";
    
    return tabela_tipos;   
}

void imprimeDeclaracoes()
{
	stringstream ss;

	for(mapa_it iterator = (*tab_variaveis).begin(); iterator != (*tab_variaveis).end(); iterator++)
	{
		if(iterator->second.nome == "")
			ss << "\t" << "CHAVE COM ERRO:" << iterator->first << ";\n";
			
		if(iterator->second.tipo == "string")
			ss << "\t" << + "char " << iterator->second.nome << "[" << iterator->second.tamanho << "];\n";
		else
			ss << "\t" << iterator->second.tipo << " " << iterator->second.nome << ";\n";
	}
	
	cout << ss.str() << "\n\t//----------------\n" << endl;
}

/*
void gera_traducao_operacoes(void)
{
	cout << "IMPRESSAO EXEMPLO:::" << E1->variavel << endl;
}


[">" ">=" "<" "<=" "==" "!="]
*/
