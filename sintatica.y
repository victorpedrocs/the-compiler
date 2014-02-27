%{
#include <stdlib.h>
#include <iostream>
#include <string.h>
#include <string>
#include <sstream>
#include <map>
#include <utility>
#include <list>
#include <vector>
#include <iterator>

#define YYSTYPE atributos

using namespace std;

typedef map<string, struct info>::iterator mapa_it;
typedef map<string, struct info> mapa;

struct atributos
{
	string traducao, variavel, tipo;
	int tamanho;

};

struct info
{
    string nome, tipo;
    int tamanho;
    vector<string> tamanho_vet;
    
};

struct info_funcao
{
    string nome, tipo;
    int quantidade;
    vector<struct info> parametros;
    unsigned short int definida;
};


#define MAX_STRING_INPUT 1000


int yylex(void);
void yyerror(string);
string gera_ID(void);
string getTipo(string, string, string);
string getTipoCast(string var1, string var2);
map<string, string> cria_tabela_tipos_retorno();
map<string, string> cria_tabela_casting();
void getDeclaracoes(mapa* mapa_variaveis);
struct info busca_no_mapa(string var);
struct info_funcao busca_funcao(string nome_funcao);
string geraLabel();
void desempilha_labels();
void desempilha_mapa();
void verifica_redeclaracao(string var);
//void verifica_parametros_funcao(string nome_funcao, vector<struct info> parametros);
//void verifica_retorno_funcao(string var_retorno, string tipo);
void insere_tab_funcoes(string nome, struct info_funcao info);
void verifica_parametros_funcao();
string busca_assinatura(string nome_funcao);
void verifica_chamadas_pendentes();
string imprime_parametros_funcao();
void atualiza_tamanho_string(string, int);
int get_tamanho_vetor(vector<string> vetor);
vector<string> calcula_posicao_vetor(string vetor_declarado);
struct atributos gera_cast(struct atributos var1, string op, struct atributos var2);

mapa* tab_variaveis = new mapa();
map<string, string> tab_tipos = cria_tabela_tipos_retorno();
map<string, string> tab_casting = cria_tabela_casting();
map<string, struct info_funcao> tab_funcoes;

string declaracoes, string_cases, funcoes;

vector<YYSTYPE> temporarias;
vector<struct info> parametros;
vector<string> string_case;
vector<struct info_funcao> funcoes_chamadas;
vector<string> tamanho_vetor;

list<mapa*> pilhaDeMapas;
list<string> pilhaDeLabelsInicio;
list<string> pilhaDeLabelsFim;



%}

%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING TK_SOMA_SUB TK_MULT_DIV TK_OP_REL TK_OP_LOG TK_IF TK_ELSE TK_CONTINUE TK_BREAK TK_DOISPONTOS TK_PRINT TK_SCAN TK_RETURN TK_OP_IGUALDADE
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_REAL TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_BOOL TK_TIPO_VOID TK_WHILE TK_DO TK_FOR TK_MM TK_SWITCH TK_CASE TK_DEFAULT
%token TK_FIM TK_ERROR

%start S


%left TK_SOMA_SUB TK_OP_REL 
%left TK_MULT_DIV
%left TK_OP_LOG
%left TK_NEG
%nonassoc IFX
%nonassoc TK_ELSE
%nonassoc '('
%nonassoc '='


%%
			
S			: ABRE_ESCOPO CODIGOS
			{
				desempilha_mapa();
				verifica_chamadas_pendentes();
				cout << "/*Compilador C'*/" << "\n#include <iostream>\n#include <string.h>\n#include<string>\n#include <stdio.h>\nusing namespace std;" << declaracoes << $2.traducao << endl;
			}
			;
			
CODIGOS		: CODIGO CODIGOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			
			|
			{
				$$.traducao = "";
			}
			;
			
CODIGO		: DECLARACAO ';'
			
			| FUNCAO
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
			
F_PARAMS_DEC: F_PARAMS_DEC ',' DECLARACAO
          	{
          		$$.traducao = $1.traducao + $3.traducao;
				parametros.push_back({$3.variavel, $3.tipo});
          	}

          	| DECLARACAO
          	{
          		$$.traducao = $1.traducao;
				parametros.push_back({$1.variavel, $1.tipo});
          	}
          	
          	| F_PARAMS_DEC ',' TIPO
          	{
          		$$.traducao = $1.traducao + $3.traducao;
          		parametros.push_back({"", $3.tipo});
          	}
          	
          	| TIPO
          	{
          		parametros.push_back({"", $1.tipo});
          	}
          	         	  	
          	|
          	{
          	   $$.traducao = "";
          	}
            ;

FUNCAO		: TIPO TK_ID ABRE_ESCOPO '(' F_PARAMS_DEC ')' BLOCO
			{
				string temp_funcao;
				if((temp_funcao = busca_assinatura($2.variavel)) == "")
					temp_funcao = gera_ID();
				
				if($2.variavel != "main")
				{
					insere_tab_funcoes($2.variavel, {temp_funcao, $1.tipo, (int)parametros.size(), parametros, 1});
					$$.traducao = "\n\n" + $1.tipo + " " + temp_funcao + "(";
				}
				else
				{
					insere_tab_funcoes($2.variavel, {$2.variavel, $1.tipo, (int)parametros.size(), parametros});
					$$.traducao = "\n\n" + $1.tipo + " main(";					
				}
				
				verifica_parametros_funcao();
				
				$$.traducao += imprime_parametros_funcao();
				$$.traducao += ")\n{\n";
				$$.traducao += declaracoes;
				$$.traducao += $7.traducao + "}";
				
				
				parametros.clear();
				desempilha_mapa();
				declaracoes = "";
			}
			
			| TIPO TK_ID ABRE_ESCOPO '(' F_PARAMS_DEC ')' ';'
			{
				string temp_funcao = gera_ID();

				insere_tab_funcoes($2.variavel, {temp_funcao, $1.tipo, (int)parametros.size(), parametros, 0});
				$$.traducao = "\n\n" + $1.tipo + " " + temp_funcao + "(";
				
				$$.traducao += imprime_parametros_funcao();
				
				$$.traducao += ");\n";
				
				parametros.clear();
				desempilha_mapa();
				declaracoes = "";
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
		
DECLARACAO	: TIPO TK_ID
            {
            	string temp_var = gera_ID();
            	verifica_redeclaracao($2.variavel);
                (*pilhaDeMapas.front())[$2.variavel] = {temp_var, $1.tipo};
                $$.variavel = temp_var;
                $$.traducao = "";
            }
            
            | TIPO TK_ID TAM_DEC_VET
            {
				string temp_var = gera_ID();
            	verifica_redeclaracao($2.variavel);
                (*pilhaDeMapas.front())[$2.variavel] = {temp_var, $1.tipo, get_tamanho_vetor(tamanho_vetor), tamanho_vetor};
                tamanho_vetor.clear();
                $$.variavel = temp_var;
                $$.traducao = "";
            }
            
            | TIPO TK_ID '=' E
            {
            
            	verifica_redeclaracao($2.variavel);
				(*pilhaDeMapas.front())[$2.variavel] = {gera_ID(), $1.tipo, $4.tamanho};
                $$.variavel = $2.variavel;//Pra Função
                if($1.tipo != $4.tipo) // então precisa fazer casting
                {
                	string tipo_cast = getTipo($1.tipo, "=", $4.tipo);
                	string temp_cast = gera_ID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
                	$$.traducao = $4.traducao + "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $4.variavel + ";\n";
                	$$.traducao += "\t" + busca_no_mapa($2.variavel).nome + " = " + temp_cast + ";\n";
                }
                
                else
                {
		            if($2.tipo == "string")
		            {
			            $$.traducao = $4.traducao + "\tstrcpy(" + busca_no_mapa($2.variavel).nome + ", " + $4.variavel + ");\n";
			            (*pilhaDeMapas.front())[$2.variavel].tamanho = $4.tamanho;
					}
			        else
			      		$$.traducao = $4.traducao + "\t" + busca_no_mapa($2.variavel).nome + " = " + $4.variavel + ";\n";
			        
		        }

            }
			
            ;
            
TAM_DEC_VET	: TAM_DEC_VET_ '[' TK_NUM ']' 
			{
				tamanho_vetor.push_back($3.traducao);
			}
			
			;
			
TAM_DEC_VET_: TAM_DEC_VET_ '[' TK_NUM ']'
			{
				tamanho_vetor.push_back($3.traducao);
			}
			
			|
			{
				$$.traducao = "";
			}

			;
            
ATRIBUICAO	: TK_ID '=' E
			{
				if(busca_no_mapa($1.variavel).tipo != $3.tipo) // então precisa fazer casting
                {
                	string tipo_cast = getTipo($1.tipo, "=", $3.tipo);
                	string temp_cast = gera_ID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
                	$$.traducao = $3.traducao + "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
                	$$.traducao += "\t" + busca_no_mapa($1.variavel).nome + " = " + temp_cast + ";\n";
                }                
                else
                {
					if(busca_no_mapa($1.variavel).tipo == "string")
					{
						$$.traducao = $3.traducao + "\tstrcpy(" + busca_no_mapa($1.variavel).nome + ", " + $3.variavel + ");\n";
						atualiza_tamanho_string($1.variavel, $3.tamanho);
					}
				
					else
						$$.traducao = $3.traducao + "\t" + busca_no_mapa($1.variavel).nome + " = " + $3.variavel + ";\n";
				}	
			}
			
			| TK_ID TAM_VET '=' E
			{
				vector<string> pos = calcula_posicao_vetor($1.variavel);
				struct info var = busca_no_mapa($1.variavel);
				$$.traducao = $2.traducao;
				$$.traducao += $4.traducao;
				$$.traducao += pos[1];
				$$.traducao += "\t" + busca_no_mapa($1.variavel).nome + "[" + pos[0] + "] = " + $4.variavel + ";\n";
				tamanho_vetor.clear();
			}
			;
			
COMANDO 	: E ';'

			| BLOCO
			
			| OPERACAO
            
            | ATRIBUICAO ';'

			| DECLARACAO ';'      
            
			| ';'
			{
				$$.traducao = "";
			}
			
			/* impressão */
            | TK_PRINT '(' E ')' ';'
            {
                $$.traducao = $3.traducao + "\tcout << " + $3.variavel + ";\n";
            }
            
            | TK_RETURN E ';'
            {
                $$.traducao = $2.traducao + "\treturn " + $2.variavel + ";\n";
            }
            
            /* entrada de usuário */
            | TK_SCAN '(' TK_ID ')' ';'
            {
            	
            	$$.traducao = "\tcin >> " + busca_no_mapa($3.variavel).nome + ";\n";
            	if(busca_no_mapa($3.variavel).tipo == "string")
            		atualiza_tamanho_string($3.variavel, MAX_STRING_INPUT);
            }
			
			/* if */
			| TK_IF '(' IF_WHILE_PARAM ')' COMANDO %prec IFX
			{
				string negacao_condicao = gera_ID();
				string label_fim_if = geraLabel();
				string label_fim_else = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao ;
				
				$$.traducao += "\n\t" + label_fim_if + ":\n";
			}

			/* if else */
			| TK_IF '(' IF_WHILE_PARAM ')' COMANDO TK_ELSE COMANDO
			{
				string negacao_condicao = gera_ID();
				string label_fim_if = geraLabel();
				string label_fim_else = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao ;
				
				$$.traducao += "\tgoto " + label_fim_else + ";\n\n\t" + label_fim_if + ":\n" + $7.traducao + "\n\t" +label_fim_else + ":\n";

			}
			
			/* while */
			| TK_WHILE ABRE_LACO '(' IF_WHILE_PARAM ')' COMANDO
			{
				string negacao_condicao = gera_ID();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $4.tipo};
				$$.traducao = "\n\t" + pilhaDeLabelsInicio.front() + ":\n" + $4.traducao + "\t" + negacao_condicao + " = !(" + $4.variavel + ");\n\tif(" + negacao_condicao + ") goto " + pilhaDeLabelsFim.front() + ";\n" + $6.traducao + "\tgoto " + pilhaDeLabelsInicio.front() + ";\n\n\t" + pilhaDeLabelsFim.front() + ":\n";
				
				desempilha_labels();
			}
			
			/* do while */
			| TK_DO ABRE_LACO COMANDO TK_WHILE '(' IF_WHILE_PARAM ')' ';'
			{
				$$.traducao = "\n\n\t" + pilhaDeLabelsInicio.front() + ":\n" + $3.traducao + $6.traducao + "\tif(" + $6.variavel + ") goto " + pilhaDeLabelsInicio.front() + ";\n\n";
				desempilha_labels();
			}
			
			/* for */
			| TK_FOR ABRE_LACO ABRE_ESCOPO '(' FOR_PARAM ';' FOR_PARAM ';' FOR_PARAM ')' COMANDO
			{
				string negacao_condicao = gera_ID();
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
			| TK_SWITCH ABRE_LACO '(' E ')' COMANDO
			{
				$$.traducao = "\n\t" + pilhaDeLabelsInicio.front() + ":\n";
				$$.traducao += $4.traducao;
				
  				for(int i = 0; i < temporarias.size(); i++)
  				{
  					string label_case = geraLabel();
  					
  					if(temporarias[i].variavel == "default")
  						$$.traducao += "\tgoto " + label_case + ";\n";

  					else
  					{
  						string var_comparacao = gera_ID();
	  					(*pilhaDeMapas.front())[var_comparacao] = {var_comparacao, "unsigned short int"};
	  					
						$$.traducao += temporarias[i].traducao + "\t" + var_comparacao + " = " + temporarias[i].variavel + " == " + $4.variavel + ";\n";
						$$.traducao += "\tif(" + var_comparacao + ") goto " + label_case + ";\n";
					}
					
					string_cases += "\n\t" + label_case + ":\n" + string_case[i];
				}
				
				$$.traducao += string_cases;
				$$.traducao += "\n\t" + pilhaDeLabelsFim.front() + ":\n";
				desempilha_labels();
				
			}
			
			/* case */
			| TK_CASE VALOR TK_DOISPONTOS COMANDO
			{
				temporarias.push_back($2);
				string_case.push_back($4.traducao);			
			}
			
			/* case default */
			| TK_DEFAULT TK_DOISPONTOS COMANDO
			{
				temporarias.push_back({"", "default"});
				string_case.push_back($3.traducao);	
			}
			
			| TK_CONTINUE ';'
			{
				$$.traducao = "\tgoto " + pilhaDeLabelsInicio.front() + ";\n";
			}
			
			| TK_BREAK ';'
			{
				$$.traducao = "\tgoto " + pilhaDeLabelsFim.front() + ";\n";
			}
            ;

F_PARAMS    : F_PARAMS ',' E
			{
				$$.traducao = $1.traducao;
				if($3.traducao != "") //É uma expressão ou valor
				{
					$$.traducao += $3.traducao;
					parametros.push_back(busca_no_mapa($3.variavel));//Adicionando a lista de parâmetros da função
				}
				else //É a derivação de um TK_ID
					parametros.push_back({$3.variavel, $3.tipo});
			}
			
			| E
			{
				if($1.traducao != "")
				{
					$$.traducao = $1.traducao;
					parametros.push_back(busca_no_mapa($1.variavel));
				}
				else 
					parametros.push_back({$1.variavel, $1.tipo});
			}

          	| F_PARAMS ',' DECLARACAO
          	{
          		$$.traducao = $1.traducao + $3.traducao;
				parametros.push_back({$3.variavel, $3.tipo});
          	}

          	| DECLARACAO
          	{
          		$$.traducao = $1.traducao;
				parametros.push_back({$1.variavel, $1.tipo});
          	}
          	         	  	
          	|
          	{
          	   $$.traducao = "";
          	}
            ;
            
IF_WHILE_PARAM	: E

            | OPERACAO
            
            ;
            
FOR_PARAM	: DECLARACAO
			
			| ATRIBUICAO
			
			| IF_WHILE_PARAM
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
				$$.variavel = gera_ID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);
                
               
        
				if($1.tipo != $3.tipo) // então precisa casting
				    $$ = gera_cast($1,$2.traducao,$3);
				    
				else
				{
				  $$.tipo = tipo_retorno;
				    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			 
				}
				//{
					/*
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
                	string temp_cast = gera_ID();
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
				
					*/
				
				
			}
			
			| E TK_MULT_DIV E
			{	
				$$.variavel = gera_ID();
				string tipo_retorno = getTipo($1.tipo, $2.traducao, $3.tipo);				
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, tipo_retorno};
				
				if($1.tipo != $3.tipo) // então precisa casting
				{
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
                	string temp_cast = gera_ID();
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
				$$.variavel = gera_ID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};		
				$$.traducao = $2.traducao + "\t" + $$.variavel + " = !(" + $2.variavel + ");\n";
			}			
			
			| VALOR
			
			| TK_STRING
			{	
				$$.variavel = gera_ID();
				$$.tamanho = (int) $1.traducao.length()-1;
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo,$$.tamanho}; // -2 para descontar as aspas
				$$.traducao = "\tstrcpy(" + $$.variavel + ", " + $1.traducao  + ");\n";
			}

			| TK_ID TK_MM
			{
				string var_temp = gera_ID();
				string var_soma = gera_ID();
				string var_incremento = busca_no_mapa($1.variavel).nome;
				char tipo_op = $2.traducao[0];
				(*pilhaDeMapas.front())[var_temp] = {var_temp, "int"};
				(*pilhaDeMapas.front())[var_soma] = {var_soma, "int"};
				$$.variavel = var_incremento;
				$$.traducao = "\t" + var_temp + " = 1;\n\t" + var_soma + " = " + var_incremento + " " + tipo_op + " " + var_temp + ";\n\t" + var_incremento + " = " + var_soma + ";\n";
			}
			
			| TK_ID %prec IFX
			{
			    
				$$.traducao = "";
		        struct info var = busca_no_mapa($1.variavel);
				$$.variavel = var.nome;
				$$.tipo = var.tipo;
				$$.tamanho = var.tamanho;
				
				
			}
			
			| TK_ID TAM_VET
			{
				vector<string> pos = calcula_posicao_vetor($1.variavel);
				struct info var = busca_no_mapa($1.variavel);
				$$.variavel = var.nome + "[" + pos[0] + "]";
				$$.traducao = $2.traducao;
				$$.traducao += pos[1];
				$$.tipo = var.tipo;
				$$.tamanho = var.tamanho;
				tamanho_vetor.clear();
			}
			
			| CHAMADA_FC
			;			
			
TAM_VET		: TAM_VET_ '[' E ']'
			{
				$$.traducao = $1.traducao + $3.traducao;
				tamanho_vetor.push_back($3.variavel);
			}
			;
			
TAM_VET_	: TAM_VET_ '[' E ']'
			{
				$$.traducao = $1.traducao + $3.traducao;			
				tamanho_vetor.push_back($3.variavel);
			}
			
			|
			{
				$$.traducao = "";
			}
			
			;
			/* Chamada de função */
CHAMADA_FC	: TK_ID '(' F_PARAMS ')'
			{   
				//verifica_parametros_funcao($1.variavel, parametros);			
				
				/*
					Adicionar cada função chamada mas não definida e adicionar a uma lista.
					No final da execução, verificar se a função foi definida alguma vez.
					Se não, erro.
				*/
				
				$$.tipo = busca_funcao($1.variavel).tipo;
				
				if(busca_funcao($1.variavel).definida == 0)						
					funcoes_chamadas.push_back({$1.variavel, "", 0, parametros});				
				
				if($$.tipo == "void")
					$$.traducao = $3.traducao + "\t" + busca_funcao($1.variavel).nome + "(";				
					
				else
				{   	
			       	$$.variavel = gera_ID();
					(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $$.tipo};
			        $$.traducao = $3.traducao + "\t" + $$.variavel + " = " + busca_funcao($1.variavel).nome + "(";
				}
						    
		 		if(parametros.size() > 0) //Verifica se a função recebeu parametros
		 		{
		 		    $$.traducao += parametros[0].nome;			
		            for(int i = 1; i < parametros.size(); i++)
		    	        $$.traducao += ", " + parametros[i].nome;	//Montando assim pra não deixar vírgulas no final        
		 		}
		        
		    	$$.traducao += ");\n";
			    parametros.clear();
			}
			;
			
TIPO		: TK_TIPO_INT | TK_TIPO_REAL | TK_TIPO_CHAR | TK_TIPO_STRING | TK_TIPO_BOOL | TK_TIPO_VOID ;

VALOR		: TK_NUM 
			{
				$$.variavel = gera_ID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			
			| TK_REAL
			{
				$$.variavel = gera_ID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			
			| TK_CHAR
			{
				$$.variavel = gera_ID();
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, $1.tipo};					
				$$.traducao = "\t" + $$.variavel + " = " + $1.traducao + ";\n";
			}
			;
	
OPERANDO    : TK_OP_REL // < > <= >=
            
            | TK_OP_LOG // && ||
            
            | TK_OP_IGUALDADE // == !=
            ;

OPERACAO    : '(' OPERACAO ')'
            {
				$$.variavel = $2.variavel;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
            }
            
            | E OPERANDO E
            {	            	
				$$.variavel = gera_ID();			
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, "unsigned short int"};
				
				if($1.tipo != $3.tipo) // então precisa casting
				{
				    
					string tipo_cast = getTipo($1.tipo, $2.traducao , $3.tipo);
					string temp_cast = gera_ID();
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
					//$$ = gera_cast($1,$2.traducao, $3);
				}
				
				$$.tipo = "unsigned short int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			}		
			
			/*
			// GERANDO SHIFT REDUCE. Precisa mesmo dessa regra? Consegui, aparentemente, continuar resolvendo tudo sem ela...
			
			| OPERACAO TK_OP_IGUALDADE OPERACAO
			{
			    $$.variavel = gera_ID();			
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, "unsigned short int"};
				
				$$.tipo = "unsigned short int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			    
			} */
			
			| E OPERANDO E OPERANDO E
			{
				cerr << "ERRO: múltiplos operadores lógicos/relacionais" << endl;
				exit(1);
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

string gera_ID()
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

map<string, string> cria_tabela_tipos_retorno()
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

struct atributos gera_cast(struct atributos var1, string op, struct atributos var2)
{
    
    if (tab_casting[var1.tipo+op+var2.tipo] == "")
    {
        cerr << "ERRO: tipos incompativeis. Nao e possivel realizar casting. (" << var1.tipo << op << var2.tipo << ")" << endl;
	    exit(EXIT_FAILURE);
    }
    else
    {
        struct atributos operacao;
        string tipo_cast = tab_casting[var1.tipo+op+var2.tipo];    
        string temp_concat = "", traducao = "", ssvariavel = gera_ID();
        int tamanho = 0;
        
        if (tipo_cast == "string") //Concatenações
        {
            if(var1.tipo == "string" && var2.tipo == "int")
            {
                        temp_concat = gera_ID();
                        traducao = var1.traducao + var2.traducao;
                        traducao += "\tsprintf(" + temp_concat + ", \"%d\"," + var2.variavel + ");\n";
                        traducao += "\tstrcpy(" + ssvariavel + ", " + var1.variavel + ");\n\tstrcat(" + ssvariavel + ", " + temp_concat + ");\n";
                        tamanho = var1.tamanho + 100;
                        (*pilhaDeMapas.front())[ssvariavel] = {ssvariavel, tipo_cast,100};
                        (*pilhaDeMapas.front())[temp_concat] = {temp_concat, tipo_cast,100};
                        operacao = {traducao, ssvariavel, tipo_cast, tamanho};
                        return operacao;
            } 
            
            if(var1.tipo == "int" && var2.tipo == "string")
            {           
                        temp_concat = gera_ID();
                        traducao = var1.traducao + var2.traducao;
                        traducao += "\tsprintf(" + temp_concat + ", \"%d\"," + var1.variavel + ");\n";
                        traducao += "\tstrcpy(" + ssvariavel + ", " + temp_concat + ");\n\tstrcat(" + ssvariavel + ", " + var2.variavel + ");\n";
                        tamanho = var2.tamanho + 100;
                        (*pilhaDeMapas.front())[ssvariavel] = {ssvariavel, tipo_cast,100};
                        (*pilhaDeMapas.front())[temp_concat] = {temp_concat, tipo_cast,100};
                        operacao = {traducao, ssvariavel, tipo_cast, tamanho};
                        return operacao;
                        
            }
            if(var1.tipo == "string" && var2.tipo == "float")
            {
                        temp_concat = gera_ID();
                        traducao = var1.traducao + var2.traducao;
                        traducao += "\tsprintf(" + temp_concat + ", \"%g\"," + var2.variavel + ");\n";
                        traducao += "\tstrcpy(" + ssvariavel + ", " + var1.variavel + ");\n\tstrcat(" + ssvariavel + ", " + temp_concat + ");\n";
                        tamanho = var1.tamanho + 100;
                        (*pilhaDeMapas.front())[ssvariavel] = {ssvariavel, tipo_cast,100};
                        (*pilhaDeMapas.front())[temp_concat] = {temp_concat, tipo_cast,100};
                        operacao = {traducao, ssvariavel, tipo_cast, tamanho};
                        return operacao;
            } 
            if(var1.tipo == "float" && var2.tipo == "string")
            {
                        temp_concat = gera_ID();
                        traducao = var1.traducao + var2.traducao;
                        traducao += "\tsprintf(" + temp_concat + ", \"%g\"," + var1.variavel + ");\n";
                        traducao += "\tstrcpy(" + ssvariavel + ", " + temp_concat + ");\n\tstrcat(" + ssvariavel + ", " + var2.variavel + ");\n";
                        tamanho = var1.tamanho + 100;
                        (*pilhaDeMapas.front())[ssvariavel] = {ssvariavel, tipo_cast,100};
                        (*pilhaDeMapas.front())[temp_concat] = {temp_concat, tipo_cast,100};
                        operacao = {traducao, ssvariavel, tipo_cast, tamanho};
                        return operacao;
            } 
        }
         
    }

}


map<string, string> cria_tabela_casting()
{
    map<string, string> tabela_casting;
    
    tabela_casting["int+string"] = "string";
    tabela_casting["string+int"] = "string";
    
    tabela_casting["float+string"] = "string";
    tabela_casting["string+float"] = "string";
    
    tabela_casting["int+float"] = "float";
    tabela_casting["float+int"] = "float";
    
   
   
   /*
    tabela_casting["int+char"] = "char"; //@TODO
    
    
    tabela_casting["string+char"] = "string";
    
    
    
    tabela_casting["float+string"] = "string";
    tabela_casting["char+string"] = "string";

    tabela_casting["int-int"] = "int";
    tabela_casting["int-float"] = "float";

    tabela_casting["int-char"] = "char"; //@TODO

    tabela_casting["int*float"] = "float";
    tabela_casting["int/float"] = "float";
    
    tabela_casting["float>int"] = "float";
    
    tabela_casting["float>=int"] = "float";
    
    tabela_casting["float<int"] = "float";
    
    tabela_casting["float<=int"] = "float";
    
    tabela_casting["float==int"] = "float";
    tabela_casting["string==char"] = "string";
    
    tabela_casting["float!=int"] = "float";
    tabela_casting["string!=char"] = "string";
    
    
    //Atribuições / Declarações
    tabela_casting["int=float"] = "int";
    tabela_casting["int=char"] = "int";
    tabela_casting["int=unsigned short int"] = "int";
    
    tabela_casting["float=int"] = "float";
    tabela_casting["float=unsigned short int"] = "float";
    
    tabela_casting["char=int"] = "char";
    
    tabela_casting["string=char"] = "string";
    
	tabela_casting["float=int"] = "float";

    tabela_casting["unsigned short int=int"] = "unsigned short int";	
    */
    return tabela_casting;   
}

void getDeclaracoes(mapa* mapa_variaveis)
{
	stringstream ss;

	for(mapa_it iterator = (*mapa_variaveis).begin(); iterator != (*mapa_variaveis).end(); iterator++)
	{
		if(iterator->second.nome == "") // TESTE
			ss << "\t" << "CHAVE COM ERRO:" << iterator->first << ";\n";
			
		if(iterator->second.tipo == "string") // imprime string como vetor de char
			ss << "\t" << "char " << iterator->second.nome << "[" << iterator->second.tamanho << "];\n";
		
		else if(iterator->second.tamanho_vet.size() != 0) // imprime tamanho do vetor
			ss << "\t" << iterator->second.tipo << " " << iterator->second.nome << "[" << iterator->second.tamanho << "];\n";
			
		else
			ss << "\t" << iterator->second.tipo << " " << iterator->second.nome << ";\n";
	}

	declaracoes += ss.str();
}


struct info busca_no_mapa(string var)
{
	list<mapa*>::iterator iterator;
	mapa_it res;
	
	for(iterator = pilhaDeMapas.begin(); iterator != pilhaDeMapas.end(); iterator++)	
		if((res = (*iterator)->find(var)) != (*iterator)->end())
			return res->second;
	
	cerr << "ERRO: Variável \"" << var << "\" não declarada nesse escopo" << endl;
	exit(1);
}

string busca_assinatura(string nome_funcao)
{
	string nome_args = nome_funcao;
	for(int i = 0; i < parametros.size(); i++)
		nome_args += parametros[i].tipo;
		
	if (tab_funcoes.find(nome_args) ==  tab_funcoes.end())         
        return "";
	else 
		return tab_funcoes.find(nome_args)->second.nome;
	
}

struct info_funcao busca_funcao(string nome_funcao)
{
	string nome_args = nome_funcao;
	for(int i = 0; i < parametros.size(); i++)
		nome_args += parametros[i].tipo;
		
	if (tab_funcoes.find(nome_args) == tab_funcoes.end())         
	{
        cerr << "ERRO: Função \"" + nome_funcao + "\" não declarada ou parâmetros incorretos." << endl;
		exit(1);
	}
	else return tab_funcoes.find(nome_args)->second;
}

/*

void verifica_parametros_funcao(string nome_funcao, vector<struct info> parametros)
{
	struct info_funcao funcao = tab_funcoes[nome_funcao];
	
	busca_funcao(nome_funcao);	
	
	if(parametros.size() != funcao.parametros.size())
	{
		cerr << "ERRO: Quantidade de parâmetros diferente do esperado." << endl;
		exit(1);
	}
			   
	
			   
	for(int i = 0; i < parametros.size(); i++)			   			
	    if (funcao.parametros[0].tipo != parametros[i].tipo)
	    {
	    	cerr << "ERRO: Parâmetros com tipos diferentes." << endl;
			exit(1);
	    }
			   
}

void verifica_retorno_funcao(string var_retorno, string tipo)
{
	if(busca_no_mapa(var_retorno).tipo != tipo)
	{
		cerr << "ERRO: Tipos diferentes." << endl;
		exit(1);
	}
}

*/
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

void insere_tab_funcoes(string nome, struct info_funcao info)
{
	/* concatena o nome da funcao com seus parametros */
	string nome_args = nome;
	for(int i = 0; i < info.quantidade; i++)
		nome_args += parametros[i].tipo;
	tab_funcoes[nome_args] = info;
}


void verifica_parametros_funcao()
{
	for(int i = 0; i < parametros.size(); i++)
	{
	   	if(parametros[i].nome == "") 
	   	{
			cerr << "ERRO: variável sem nome definido" << endl;
			exit(1);
	  	}
	}
}

void verifica_chamadas_pendentes()
{
	string nome_args;
	
	for(int i = 0; i < funcoes_chamadas.size(); i++)
	{
		nome_args = funcoes_chamadas[i].nome;
		for(int j = 0; j < funcoes_chamadas[i].parametros.size(); j++)
			nome_args += funcoes_chamadas[i].parametros[j].tipo;
			
		if(busca_funcao(nome_args).definida == 0)
		{
			cerr << "ERRO: Função \"" << funcoes_chamadas[i].nome << "\" chamada mas não definida." << endl;
			exit(1);
		}
	}
}

string imprime_parametros_funcao()
{
	string params;
	if(parametros.size() > 0) //Verifica se a função recebeu parametros
	{
		params += parametros[0].tipo + " " + parametros[0].nome;
		for(int i = 1; i < parametros.size(); i++)
			params += ", " + parametros[i].tipo + " " + parametros[i].nome;
			
		return params;
	}
	else
		return "";
	
}

void atualiza_tamanho_string(string nome, int tamanho)
{
	
	list<mapa*>::iterator iterator;
	mapa_it res;
	
	for(iterator = pilhaDeMapas.begin(); iterator != pilhaDeMapas.end(); iterator++)	
		if((res = (*iterator)->find(nome)) != (*iterator)->end())
		{
			res->second.tamanho = tamanho;
			break;
		}
}

int get_tamanho_vetor(vector<string> vetor)
{
	int tam = 1;
	for(int i = 0; i < vetor.size(); i++)
		tam *= atoi(vetor[i].c_str());
	return tam;
}

vector<string> calcula_posicao_vetor(string vetor_declarado)
{
	vector<string> tamanhos_chamada = tamanho_vetor;
	vector<string> tamanhos_declaracao = busca_no_mapa(vetor_declarado).tamanho_vet;
	vector<string> retorno;
	string traducao = "";
	
	string temp_aux = gera_ID();
	(*pilhaDeMapas.front())[temp_aux] = {temp_aux, "int"};
	
	string temp_pos = gera_ID();
	(*pilhaDeMapas.front())[temp_pos] = {temp_pos, "int"};
	
	string temp_aux2 = gera_ID();
	(*pilhaDeMapas.front())[temp_aux2] = {temp_aux2, "int"};
	
	traducao += "\t" + temp_pos + " = 0;//83\n";
	
	//int aux, pos = 0; @here
	
	for(int i = 0; i < tamanhos_declaracao.size(); i++)
	{
		//aux = tamanhos_chamada[i];
		traducao += "\t" + temp_aux + " = " + tamanhos_chamada[i] + ";//1190\n";
		
		for(int j = (tamanhos_declaracao.size() - 1); j > i; j--)
		{
			//aux *= tamanhos_declaracao[j];
			traducao += "\t" + temp_aux2 + " = " + tamanhos_declaracao[j] + ";//95\n"; 
			traducao += "\t" + temp_aux + " = " + temp_aux + " * " + temp_aux2 + ";//96\n";
		}
		
		//pos += aux;
		traducao += "\t" + temp_pos + " = " + temp_pos + " + " + temp_aux + ";//1200\n";
	}
	
	retorno.push_back(temp_pos);
	retorno.push_back(traducao);
	
	return retorno;
}

/*

http://www.quut.com/c/ANSI-C-grammar-y.html

*/
