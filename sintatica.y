%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <utility>
#include <list>
#include <vector>

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
string buscaFuncao(string nome_funcao);
string geraLabel();
void desempilha_labels();
void desempilha_mapa();
void verifica_redeclaracao(string var);

mapa* tab_variaveis = new mapa();
map<string, string> tab_tipos = cria_tabela_tipos();
map<string, string> tab_funcoes;

string declaracoes, string_cases, funcoes;


vector<YYSTYPE> temporarias;
vector<struct variavel> parametros;
vector<string> string_case;

list<mapa*> pilhaDeMapas;
list<string> pilhaDeLabelsInicio;
list<string> pilhaDeLabelsFim;



%}

%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING TK_SOMA_SUB TK_MULT_DIV TK_OP_REL TK_OP_LOG TK_IF TK_ELSE TK_CONTINUE TK_BREAK TK_DOISPONTOS TK_PRINT TK_SCAN TK_RETURN 
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_REAL TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_BOOL TK_WHILE TK_DO TK_FOR TK_MM TK_SWITCH TK_CASE TK_NOME_FUNCAO
%token TK_FIM TK_ERROR

%start S


%left TK_SOMA_SUB TK_OP_REL 
%left TK_MULT_DIV
%left TK_OP_LOG
%left TK_NEG
%nonassoc IFX
%nonassoc TK_ELSE


%%

S			: ABRE_ESCOPO DECLARACOES MAIN
			{
				desempilha_mapa();
				cout << "/*Compilador C'*/" << "\n#include <iostream>\n#include <string.h>\n\nusing namespace std;\n" << funcoes << "\nint main(void)\n{\n" << declaracoes  <<"\t//-------------\n" << $2.traducao << $3.traducao << "\n}" << endl; 
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
				desempilha_mapa();
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

DECLARACAO	: TIPO TK_ID
            {
            	verifica_redeclaracao($2.variavel);
                (*pilhaDeMapas.front())[$2.variavel] = {getID(), $1.tipo};   
                $$.variavel = $2.variavel; //Pra Função
                $$.traducao = "";
            }
            
            | TIPO TK_ID '=' E
            {
            	verifica_redeclaracao($2.variavel);
				(*pilhaDeMapas.front())[$2.variavel] = {getID(), $1.tipo, $4.tamanho};
                $$.variavel = $2.variavel;//Pra Função
                
                if($1.tipo != $4.tipo) // então precisa fazer casting
                {
                	string tipo_cast = getTipo($1.tipo, "=", $4.tipo);
                	string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
                	$$.traducao = $4.traducao + "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $4.variavel + ";\n";
                	$$.traducao += "\t" + buscaNoMapa($2.variavel).nome + " = " + temp_cast + ";\n";
                }
                
                else
                {
		            if($2.tipo == "string")
		            {
			            $$.traducao = $4.traducao + "\tstrcpy(" + buscaNoMapa($2.variavel).nome + ", " + $4.variavel + ");\n";
			            (*pilhaDeMapas.front())[$2.variavel].tamanho = $4.tamanho;
					}
			        else
			      		$$.traducao = $4.traducao + "\t" + buscaNoMapa($2.variavel).nome + " = " + $4.variavel + ";\n";
			        
		        }

            }
            
            ;
            
ATRIBUICAO	: TK_ID '=' E
			{
			
				if($1.tipo != $3.tipo) // então precisa fazer casting
                {
                	string tipo_cast = getTipo($1.tipo, "=", $3.tipo);
                	string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
                	$$.traducao = $3.traducao + "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
                	$$.traducao += "\t" + buscaNoMapa($1.variavel).nome + " = " + temp_cast + ";\n";
                }
                
                else
                {
					if($$.tipo == "string")
					{
						$$.traducao = $3.traducao + "\tstrcpy(" + buscaNoMapa($1.variavel).nome + ", " + $3.variavel + ");\n";
						(*pilhaDeMapas.front())[$1.variavel].tamanho = $3.tamanho;
					}
				
					else
						$$.traducao = $3.traducao + "\t" + buscaNoMapa($1.variavel).nome + " = " + $3.variavel + ";\n";
				}	
			}
			;
			/*
ELSE		: TK_ELSE COMANDO
			{
				$$.traducao = $2.traducao;
			}
			
			/*
			|
			{
				$$.traducao = "";
			}
			
			;
			*/
			
COMANDO 	: E ';'

			| BLOCO
            
            | ATRIBUICAO ';'

			| DECLARACAO ';'      
            
			| ';'
			{
				$$.traducao = "";
			}
			
			/* impressão */
            | TK_PRINT '(' E ')' ';'
            {
                $$.traducao = $3.traducao + "\tcout << " + $3.variavel + " << endl;\n";
            }
            
            | TK_RETURN E ';'
            {
                $$.traducao = $2.traducao + "\treturn " + $2.variavel + ";\n";
            }
            
            /* entrada de usuário */
            
            | TK_SCAN '(' TK_ID ')' ';'
            {
            	$$.traducao = $3.traducao + "\tcin >> " + buscaNoMapa($3.variavel).nome + ";\n";
            }
			
			/* if */
			| TK_IF '(' E ')' COMANDO %prec IFX
			{
				string negacao_condicao = getID();
				string label_fim_if = geraLabel();
				string label_fim_else = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao ;
				
				$$.traducao += "\n\t" + label_fim_if + ":\n";
			}

			/* if else */
			| TK_IF '(' E ')' COMANDO TK_ELSE COMANDO
			{
				string negacao_condicao = getID();
				string label_fim_if = geraLabel();
				string label_fim_else = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao ;
				
				$$.traducao += "\tgoto " + label_fim_else + ";\n\n\t" + label_fim_if + ":\n" + $7.traducao + "\n\t" +label_fim_else + ":\n";

			}
			
			/* while */
			| TK_WHILE ABRE_LACO '(' E ')' COMANDO
			{
				string negacao_condicao = getID();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $4.tipo};
				$$.traducao = "\n\t" + pilhaDeLabelsInicio.front() + ":\n" + $4.traducao + "\t" + negacao_condicao + " = !(" + $4.variavel + ");\n\tif(" + negacao_condicao + ") goto " + pilhaDeLabelsFim.front() + ";\n" + $6.traducao + "\tgoto " + pilhaDeLabelsInicio.front() + ";\n\n\t" + pilhaDeLabelsFim.front() + ":\n";
				
				desempilha_labels();
			}
			
			/* do while */
			| TK_DO ABRE_LACO COMANDO TK_WHILE '(' E ')' ';'
			{
				$$.traducao = "\n\n\t" + pilhaDeLabelsInicio.front() + ":\n" + $3.traducao + $6.traducao + "\tif(" + $6.variavel + ") goto " + pilhaDeLabelsInicio.front() + ";\n\n";
				desempilha_labels();
			}
			
			/* for */
			| TK_FOR ABRE_LACO ABRE_ESCOPO '(' FOR_PARAM ';' FOR_PARAM ';' FOR_PARAM ')' COMANDO
			{
				string negacao_condicao = getID();
				string label_inicio = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $6.tipo};
				
				$$.traducao = $5.traducao;
				$$.traducao += "\n\t" + label_inicio + ":\n";
				$$.traducao += $7.traducao + "\t" + negacao_condicao + " = !(" + $7.variavel + ");\n\t";
				$$.traducao += "if(" + negacao_condicao + ") goto " + pilhaDeLabelsFim.front() + ";\n";
				$$.traducao += $11.traducao + "\n\t" + pilhaDeLabelsInicio.front() + ":\n" + $9.traducao;
				$$.traducao += "\tgoto " + label_inicio + ";\n\n\t" + pilhaDeLabelsFim.front() + ":\n";
				
				desempilha_labels();
				desempilha_mapa();
			
			}
			
			/* switch */
			| TK_SWITCH '(' E ')' COMANDO
			{
				$$.traducao = $3.traducao;
				
  				for(int i = 0; i < temporarias.size(); i++)
  				{
  					string var_comparacao = getID();
  					string label_case = geraLabel();
  					(*pilhaDeMapas.front())[var_comparacao] = {var_comparacao, "unsigned short int"};
  					
					$$.traducao += temporarias[i].traducao + "\t" + var_comparacao + " = " + temporarias[i].variavel + " == " + $3.variavel + ";\n";
					$$.traducao += "\tif(" + var_comparacao + ") goto " + label_case + ";\n";
					string_cases += "\n\t" + label_case + ":\n" + string_case[i];
				}
					 
				$$.traducao += string_cases;
			}
			
			/* case */
			| TK_CASE VALOR TK_DOISPONTOS COMANDO
			{

				temporarias.push_back($2);
				string_case.push_back($4.traducao);			
				
			}
			
			| TK_CONTINUE ';'
			{
				$$.traducao = "\tgoto " + pilhaDeLabelsInicio.front() + ";\n";
			}
			
			| TK_BREAK ';'
			{
				$$.traducao = "\tgoto " + pilhaDeLabelsFim.front() + ";\n";
			}
			
		
	
			/*
			Assinatura  da Função 
			| TIPO TK_ID '('F_PARAMS')'';'
			{	
			    $$.traducao = ""; 
				
			}
			*/
			
			//Chamada da Função
			| TK_ID '=' TK_ID '('F_PARAMS')'';'
			{   
			   
			   if(buscaFuncao($3.variavel) != "NULL") //Se a função já foi declarada
			   {
			       
			        $$.traducao = $5.traducao;
			        $$.traducao += "\t" + buscaNoMapa($1.variavel).nome + " = " + buscaFuncao($3.variavel) + "(";
			    
			 		if(parametros.size() > 0) //Verifica se a função recebeu parametros
			 		{
			 		    $$.traducao += parametros[0].nome;			
			            for(int i = 1; i < parametros.size(); i++)
			    	        $$.traducao += ", " + parametros[i].nome;	//Montando assim pra não deixar vírgulas no final        
			 		}
			        
			    	$$.traducao += ");\n";
				    parametros.clear();
			    }
			    
			    
			}
			| DECLARACAO ABRE_ESCOPO '(' F_PARAMS ')' COMANDO
			{
	            string temp_funcao = getID();
				tab_funcoes[$1.variavel] = temp_funcao; 
				
			
				funcoes += "\n\t" + $1.tipo + " " + temp_funcao + '(';
				
				if(parametros.size() > 0)
				{
			        funcoes += parametros[0].tipo + " " + parametros[0].nome;
			        for(int i = 1; i < parametros.size(); i++)
			    	    funcoes += ", " + parametros[i].tipo + " " + parametros[i].nome;
				}	
				
				funcoes += "){\n\t";
				funcoes += $6.traducao + "}\n\t";
				
				parametros.clear();
				
			}
            ;
    

                       
F_PARAMS    : F_PARAMS ',' E
             {
             	$$.traducao = $1.traducao + $3.traducao;
             	$$.variavel = $3.variavel;
				$$.tipo = $3.tipo;
			
				parametros.push_back(buscaNoMapa($3.variavel));//Adicionando a lista de parâmetros da função
             }
             
             | E
             {
             	$$.traducao = $1.traducao;
             	$$.variavel = $1.variavel;
				$$.tipo = $1.tipo;
				  
				parametros.push_back(buscaNoMapa($1.variavel));
             }
          	
          	| F_PARAMS ',' TIPO TK_ID
          	{
          	    $$.traducao = "";
				parametros.push_back({getID(), $4.tipo});
          	}
          	
          	| TIPO TK_ID
          	{
      	
                $$.traducao = "";
				parametros.push_back({getID(), $2.tipo});	
          	}
          	
          	|
          	{
          	    $$.traducao = "";
          	}
            ;
            
 
FOR_PARAM	: DECLARACAO
			
			| ATRIBUICAO
			
			| E

			;
			
			
ABRE_LACO	: 
			{
				string label_inicio_while = geraLabel();
				string label_fim_while = geraLabel();

				pilhaDeLabelsInicio.push_front(label_inicio_while);
				pilhaDeLabelsFim.push_front(label_fim_while);	
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

				if($1.tipo != $3.tipo) // então precisa casting
				{
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
                	string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
					
					if($1.tipo != tipo_cast)
					{
						$1.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				
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
				
				if($1.tipo != $3.tipo) // então precisa casting
				{
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
                	string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
					
					if($1.tipo != tipo_cast)
					{
						$1.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				
				$$.tipo = tipo_retorno;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			| E TK_OP_LOG E
			{	
				$$.variavel = getID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno};
				
				if($1.tipo != $3.tipo) // então precisa casting
				{
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
                	string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
					
					if($1.tipo != tipo_cast)
					{
						$1.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
						$1.tipo = tipo_retorno;
					}
					else
					{
						$3.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
						$3.tipo = tipo_retorno;
					}
				}
				
				$$.tipo = tipo_retorno;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			| TK_NEG E
			{
				$$.variavel = getID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};		
				$$.traducao = $2.traducao + "\t" + $$.variavel + " = !(" + $2.variavel + ");\n";
			}			
			
			| VALOR
			
			
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
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, "unsigned short int"};
				
				if($1.tipo != $3.tipo) // então precisa casting
				{
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
					string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, "unsigned short int"};
                	
					if($1.tipo != tipo_cast)
					{
						$1.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $1.variavel + ";\n";
						$1.variavel = temp_cast;
					}
					else
					{
						$3.traducao += "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
						$3.variavel = temp_cast;
					}
				}
				
				$$.tipo = "unsigned short int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}
			
			| TK_ID TK_MM
			{
				string var_temp = getID();
				string var_soma = getID();
				string var_incremento = buscaNoMapa($1.variavel).nome;
				char tipo_op = $2.traducao[0];
				(*pilhaDeMapas.front())[var_temp] = {var_temp, "int"};
				(*pilhaDeMapas.front())[var_soma] = {var_soma, "int"};
				$$.variavel = var_incremento;
				$$.traducao = "\t" + var_temp + " = 1;\n\t" + var_soma + " = " + var_incremento + " " + tipo_op + " " + var_temp + ";\n\t" + var_incremento + " = " + var_soma + ";\n";
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

VALOR		: TK_NUM 
			{
				$$.variavel = getID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			| TK_REAL
			{
				$$.variavel = getID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			| TK_CHAR
			{
				$$.variavel = getID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
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

	if(op != "=") // atribuicao é simétrica
	{
		tipo_retorno = tab_tipos[var2+op+var1];
		if(tipo_retorno != "")
			return tipo_retorno;
	}
	
	cerr << "ERRO: tipos incompativeis (" << var1 << op << var2 << ")" << endl;
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
    
	// Para operadores relacionais e atribuicao, a tabela da o tipo de cast6  
    //tabela_tipos["int>int"] = "int";
    //tabela_tipos["float>float"] = "int";
    tabela_tipos["float>int"] = "float";
    //tabela_tipos["char>char"] = "int";    
	//tabela_tipos["string>string"] = "int"; //@ TODO

    //tabela_tipos["int>=int"] = "int";
    //tabela_tipos["float>=float"] = "int";
    tabela_tipos["float>=int"] = "float";
    //tabela_tipos["char>=char"] = "int";
    //tabela_tipos["string>=string"] = "int"; //@ TODO
    
    //tabela_tipos["int<int"] = "int";
    //tabela_tipos["float<float"] = "";
    tabela_tipos["float<int"] = "float";
    //tabela_tipos["char<char"] = "int";
    //tabela_tipos["string<string"] = "int";
    
    //tabela_tipos["int<=int"] = "int";
    //tabela_tipos["float<=float"] = "int";
    tabela_tipos["float<=int"] = "float";
    //tabela_tipos["char<=char"] = "int";
    //tabela_tipos["string<=string"] = "int"; //@ TODO
    
    //tabela_tipos["int==int"] = "int";
    //tabela_tipos["float==float"] = "int";
    tabela_tipos["float==int"] = "float";
    //tabela_tipos["char==char"] = "int";
    //tabela_tipos["string==string"] = "int";
    
    //tabela_tipos["int!=int"] = "int";
    //tabela_tipos["float!=float"] = "int";
    tabela_tipos["float!=int"] = "float";
    //tabela_tipos["char!=char"] = "int";
    //tabela_tipos["string!=string"] = "int";
    
    //tabela_tipos["int&&int"] = "int";
    //tabela_tipos["int||int"] = "int";
    
    tabela_tipos["int=float"] = "int";
    tabela_tipos["int=char"] = "int";
    tabela_tipos["int=unsigned short int"] = "int";
    
    tabela_tipos["float=int"] = "float";
    tabela_tipos["float=unsigned short int"] = "float";
    
    tabela_tipos["char=int"] = "char";
    
    tabela_tipos["string=char"] = "string";
    
	tabela_tipos["float=int"] = "float";

    tabela_tipos["unsigned short int=int"] = "unsigned short int";	
    
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
			ss << "\t" << "char " << iterator->second.nome << "[" << iterator->second.tamanho << "];\n";
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
	
	cerr << "ERRO: Variável \"" << var << "\" não declarada nesse escopo" << endl;
	exit(1);
}

string buscaFuncao(string nome_funcao)
{
	if (tab_funcoes.find(nome_funcao) ==  tab_funcoes.end()) 
	{
        cerr << "ERRO: Função \"" + nome_funcao + "\" não declarada anteriormente."	<< endl;
        return "NULL";
	}
	else
        return tab_funcoes.find(nome_funcao)->second;
}

void desempilha_labels()
{
	pilhaDeLabelsFim.pop_front();
	pilhaDeLabelsInicio.pop_front();
}

void desempilha_mapa()
{
	getDeclaracoes(pilhaDeMapas.front());
	pilhaDeMapas.pop_front();
}

void verifica_redeclaracao(string var)
{
	list<mapa*>::iterator iterator;
	mapa_it res;
	
	for(iterator = pilhaDeMapas.begin(); iterator != pilhaDeMapas.end(); iterator++)
		if((res = (*iterator)->find(var)) != (*iterator)->end())
		{
			cerr << "Redeclaração de variável: " << var << " já declarada anteriormente" << endl;
			exit(1);
		}
}
/*

http://www.quut.com/c/ANSI-C-grammar-y.html

*/
