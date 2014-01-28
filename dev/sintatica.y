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
void getDeclaracoes(mapa* mapa_variaveis);
struct variavel buscaNoMapa(string var);
string geraLabel();

mapa* tab_variaveis = new mapa();
map<string, string> tab_tipos = cria_tabela_tipos();
string declaracoes;

list<mapa*> pilhaDeMapas;

%}

%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING TK_SOMA_SUB TK_MULT_DIV TK_OP_REL TK_OP_LOG
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_REAL TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_BOOL TK_IF
%token TK_FIM TK_ERROR

%start S

%left TK_SOMA_SUB TK_OP_REL 
%left TK_MULT_DIV
%left TK_OP_LOG


%%

S			: ABRE_ESCOPO DECLARACOES MAIN
			{
				getDeclaracoes(pilhaDeMapas.front());
				pilhaDeMapas.pop_front();
				cout << "/*Compilador C'*/\n" << "#include<stdio.h>\n#include<string.h>\nint main(void)\n{\n" << declaracoes << "\t//-------------\n" << $2.traducao << $3.traducao << "\treturn 0;\n}" << endl; 
			}
			;

MAIN		: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				$$.traducao = $5.traducao;
			}
			;
			
BLOCO		: '{' ABRE_ESCOPO COMANDOS '}'
			{
				$$.traducao = $3.traducao;
				getDeclaracoes(pilhaDeMapas.front());		// guarda as declarações do mapa que vai ser desempilhado
				pilhaDeMapas.pop_front();					// Desempilha o mapa
			}
			;
			
ABRE_ESCOPO	:
			{
				mapa* mapa_var = new mapa();
				pilhaDeMapas.push_front(mapa_var);
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

DECLARACOES	: DECLARACOES DECLARACAO
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			
			|
			{
				$$.traducao = "";
			}
			;

DECLARACAO	: TIPO TK_ID ';'
            {
                (*pilhaDeMapas.front())[$2.variavel] = {getID(), $1.tipo};
                $$.traducao = "";
            }
            
            | TIPO TK_ID '=' E ';'
            {
				(*pilhaDeMapas.front())[$2.variavel] = {getID(), $1.tipo, $4.tamanho};
                
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
	                $$.traducao = $4.traducao + "\tstrcpy(" + buscaNoMapa($2.variavel).nome + ", " + $4.variavel + ");\n";                	
	            else
	            {
	                $$.traducao = $4.traducao + "\t" + buscaNoMapa($2.variavel).nome + " = " + $4.variavel + ";\n";
	                //cout << "minha traducao é: " << $$.traducao << endl;
               	}
                (*pilhaDeMapas.front())[$2.variavel].tamanho = $4.tamanho;

            }
            ;
            

COMANDO 	: E ';'

			| BLOCO
			{
				$$.traducao = $1.traducao;
			}
            
            | TK_ID '=' E ';'
			{
				if($$.tipo == "string")
					$$.traducao = $3.traducao + "\tstrcpy(" + buscaNoMapa($1.variavel).nome + ", " + $3.variavel + ");\n";
				else
					$$.traducao = $3.traducao + "\t" + buscaNoMapa($1.variavel).nome + " = " + $3.variavel + ";\n";
				
				(*pilhaDeMapas.front())[$1.variavel].tamanho = $3.tamanho;
			}
			
			| DECLARACAO
            {
                $$.traducao = $1.traducao;
            }
			
			| TK_IF '(' E ')' COMANDO
			{
				string negacao_condicao = getID();
				string label_fim_if = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao + "\t" + label_fim_if + ":\n";
			}
            ;

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
					(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno, $$.tamanho};
					
				}

				else
				{
					$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";	
					(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno};
				}	
				
				$$.tipo = tipo_retorno;
				
			}
			
			| E TK_MULT_DIV E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno};
				
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
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno};
				
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
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			
			| TK_STRING
			{	
				$$.variavel = getID();
				$$.tamanho = (int) $1.traducao.length()-2;
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo, $$.tamanho}; // -2 para descontar as aspas
				$$.traducao = "\tstrcpy(" + $$.variavel + ", " + $1.traducao + ");\n";
			}
			
			| E TK_OP_REL E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno};
				
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
				struct variavel var = buscaNoMapa($1.variavel);
				$$.variavel = var.nome;
				$$.tipo = var.tipo;
				$$.tamanho = var.tamanho;
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

string geraLabel()
{
	static int i = 0;

	stringstream ss;
	ss << "label" << i++;
	
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

	cout << "Erro: tipos incompativeis (" << var1 << op << var2 << ")" << endl;
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

void getDeclaracoes(mapa* mapa_variaveis)
{
	stringstream ss;

	for(mapa_it iterator = (*mapa_variaveis).begin(); iterator != (*mapa_variaveis).end(); iterator++)
	{
		if(iterator->second.nome == "")
			ss << "\t" << "CHAVE COM ERRO:" << iterator->first << ";\n";
			
		if(iterator->second.tipo == "string")
			ss << "\t" << + "char " << iterator->second.nome << "[" << iterator->second.tamanho << "];\n";
		else
			ss << "\t" << iterator->second.tipo << " " << iterator->second.nome << ";\n";
	}
	
	declaracoes += ss.str();
	
}


struct variavel buscaNoMapa(string var)
{
	list<mapa*>::iterator iterator;
	mapa_it res;
	
	for(iterator = pilhaDeMapas.begin(); iterator != pilhaDeMapas.end(); iterator++)	
		if((res = (*iterator)->find(var)) != (*iterator)->end())
			return res->second;
	
	cout << "Variável \"" << var << "\" não declarada nesse escopo" << endl;
	exit(0);
}
