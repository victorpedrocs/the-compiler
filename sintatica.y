%{
#include <iostream>
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
    vector<int> tamanho_vet;
};

struct info_funcao
{
    string nome, tipo;
    int quantidade;
    vector<struct info> parametros;
};

int yylex(void);
void yyerror(string);
string getID(void);
string getTipo(string, string, string);
string getTipoCast(string var1, string var2);
map<string, string> cria_tabela_tipos();
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
vector<int> trata_tamanho(string tamanhos);
vector<string> calcula_posicao_vetor(string vetor_declarado, string tamanho);
vector<int> trata_tamanho(string tamanhos);

mapa* tab_variaveis = new mapa();
map<string, string> tab_tipos = cria_tabela_tipos();
map<string, struct info_funcao> tab_funcoes;

string declaracoes, string_cases, funcoes;


vector<YYSTYPE> temporarias;
vector<struct info> parametros;
vector<string> string_case;

list<mapa*> pilhaDeMapas;
list<string> pilhaDeLabelsInicio;
list<string> pilhaDeLabelsFim;



%}

%token TK_NUM TK_REAL TK_BOOL TK_CHAR TK_STRING TK_SOMA_SUB TK_MULT_DIV TK_OP_REL TK_OP_LOG TK_IF TK_ELSE TK_CONTINUE TK_BREAK TK_DOISPONTOS TK_PRINT TK_SCAN TK_RETURN TK_OP_IGUALDADE TK_TAM_VET
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_REAL TK_TIPO_CHAR TK_TIPO_STRING TK_TIPO_BOOL TK_TIPO_VOID TK_WHILE TK_DO TK_FOR TK_MM TK_SWITCH TK_CASE 
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
				cout << "/*Compilador C'*/" << "\n#include <iostream>\n#include <string.h>\n\nusing namespace std;" << declaracoes << $2.traducao << endl;
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

			/*| TIPO TK_ID '(' ')' ';'
			{
				$$.traducao = "encontrei um assinatura";
			}
			*/

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

FUNCAO		: TIPO TK_ID ABRE_ESCOPO '(' F_PARAMS ')' BLOCO
			{
				
				if($2.variavel != "main")
				{
	            	string temp_funcao = getID();
					insere_tab_funcoes($2.variavel, {temp_funcao, $1.tipo, (int)parametros.size(), parametros});
					$$.traducao = "\n\n" + $1.tipo + " " + temp_funcao + "(";
				}
				else
				{
					insere_tab_funcoes($2.variavel, {$2.variavel, $1.tipo, (int)parametros.size(), parametros});
					$$.traducao = "\n\n" + $1.tipo + " main(";					
				}
				
				if(parametros.size() > 0)
				{
			        $$.traducao += parametros[0].tipo + " " + parametros[0].nome;
			        for(int i = 1; i < parametros.size(); i++)
			    	    $$.traducao += ", " + parametros[i].tipo + " " + parametros[i].nome;
				}	
				
				$$.traducao += ")\n{\n";
				$$.traducao += declaracoes;
				$$.traducao += $7.traducao + "}";
				
				
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
/*			
DECLARACOES	: DECLARACAO DECLARACOES
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			
			|
			{
				$$.traducao = "";
			}
			;
*/			
DECLARACAO	: TIPO TK_ID
            {
            	string temp_var = getID();
            	verifica_redeclaracao($2.variavel);
                (*pilhaDeMapas.front())[$2.variavel] = {temp_var, $1.tipo};
                $$.variavel = temp_var;
                $$.traducao = "";
            }
            /*
            | TIPO TK_ID '(' DECLARACOES ')'
            {
            	cerr << "passei aqui" << endl;
            	$$.traducao = "";
            }
            */
            | TIPO TK_ID TK_TAM_VET
            {
            	string temp_var = getID();
				verifica_redeclaracao($2.variavel);
				trata_tamanho($3.traducao);
				vector<int> vet_tamanhos = trata_tamanho($3.traducao);
				int tamanho = 1;
				for(int i = 0; i < vet_tamanhos.size(); i++)
					tamanho *= vet_tamanhos[i];
				(*pilhaDeMapas.front())[$2.variavel] = {temp_var, $1.tipo, tamanho, vet_tamanhos};
				$$.variavel = temp_var;
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
            
ATRIBUICAO	: TK_ID '=' E
			{
				if(busca_no_mapa($1.variavel).tipo != $3.tipo) // então precisa fazer casting
                {
                	string tipo_cast = getTipo($1.tipo, "=", $3.tipo);
                	string temp_cast = getID();
                	(*pilhaDeMapas.front())[temp_cast] = {temp_cast, tipo_cast};
                	$$.traducao = $3.traducao + "\t" + temp_cast + " = " + "(" + tipo_cast + ")" + $3.variavel + ";\n";
                	$$.traducao += "\t" + busca_no_mapa($1.variavel).nome + " = " + temp_cast + ";\n";
                }
                
                else
                {
					if($1.tipo == "string")
					{
						$$.traducao = $3.traducao + "\tstrcpy(" + busca_no_mapa($1.variavel).nome + ", " + $3.variavel + ");\n";
						(*pilhaDeMapas.front())[$1.variavel].tamanho = $3.tamanho; // ERRO!!! Não está necessariamente no mapa do topo
					}
				
					else
						$$.traducao = $3.traducao + "\t" + busca_no_mapa($1.variavel).nome + " = " + $3.variavel + ";\n";
				}	
			}
			
			| TK_ID TK_TAM_VET '=' E
			{
			
				// falta o casting, tirei pra não poluir

				vector<string> pos = calcula_posicao_vetor($1.variavel, $2.traducao);
				$$.traducao = $4.traducao + pos[1] + "\t" + busca_no_mapa($1.variavel).nome + "[" + pos[0] + "] = " + $4.variavel + ";\n";	
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
                $$.traducao = $3.traducao + "\tcout << " + $3.variavel + "<< endl;\n";
            }
            
            | TK_RETURN E ';'
            {
                $$.traducao = $2.traducao + "\treturn " + $2.variavel + ";\n";
            }
            
            /* entrada de usuário */
            | TK_SCAN '(' TK_ID ')' ';'
            {
            	$$.traducao = $3.traducao + "\tcin >> " + busca_no_mapa($3.variavel).nome + ";\n";
            }
			
			/* if */
			| TK_IF '(' IF_WHILE_PARAM ')' COMANDO %prec IFX
			{
				string negacao_condicao = getID();
				string label_fim_if = geraLabel();
				string label_fim_else = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao ;
				
				$$.traducao += "\n\t" + label_fim_if + ":\n";
			}

			/* if else */
			| TK_IF '(' IF_WHILE_PARAM ')' COMANDO TK_ELSE COMANDO
			{
				string negacao_condicao = getID();
				string label_fim_if = geraLabel();
				string label_fim_else = geraLabel();
				(*pilhaDeMapas.front())[negacao_condicao] = {negacao_condicao, $3.tipo}; // criando e adicionando a variável que vai guardar a negacao da condicao
				
				$$.traducao = $3.traducao + "\t" +  negacao_condicao + " = !(" + $3.variavel + ");\n\tif(" + negacao_condicao + ") goto " + label_fim_if + ";\n" + $5.traducao ;
				
				$$.traducao += "\tgoto " + label_fim_else + ";\n\n\t" + label_fim_if + ":\n" + $7.traducao + "\n\t" +label_fim_else + ":\n";

			}
			
			/* while */
			| TK_WHILE ABRE_LACO '(' IF_WHILE_PARAM ')' COMANDO
			{
				string negacao_condicao = getID();
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

			| TK_ID TK_MM
			{
				string var_temp = getID();
				string var_soma = getID();
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
			
			| TK_ID TK_TAM_VET
			{
				vector<string> pos = calcula_posicao_vetor($1.variavel, $2.traducao);
				struct info var = busca_no_mapa($1.variavel);
				$$.variavel = var.nome + "[" + pos[0] + "]";
				$$.traducao = pos[1];
				$$.tipo = var.tipo;
				$$.tamanho = var.tamanho;
			}
			
			| CHAMADA_FC
			;
			/* Chamada de função */

CHAMADA_FC	: TK_ID '(' F_PARAMS ')'
			{   
					//verifica_parametros_funcao($1.variavel, parametros);

					$$.tipo = busca_funcao($1.variavel).tipo;
					
					if($$.tipo == "void")
						$$.traducao = $3.traducao + "\t" + busca_funcao($1.variavel).nome + "(";				
						
					else
					{   	
				       	$$.variavel = getID();
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
			
	/*
	    Tive uma ideia para resolver o problema dos múltiplos operadores lógicos e relacionais,
	    sei que não é importante, mas queria dar uma pausa em funções.
	    Enfim, a ideia é não permitir que E derive para E OP_LOG / OP_REL E. 
	    Pois é isso que faz com que o operador também possa ser uma operação.
	    A proposta é fazer comando derivar para operação. E os operandos podem ser E, 
	    pois E se resumiu agora a operações aritméticas, variáveis e valores.
	    
	    -- Operação com 2 operandos está OK
	    -- Comparação de operações ex.: OK
	    -- Falta tratamento de erros da nossa parte para mais de 2 operandos nas operações, pois como limitei a 2,
	    quando ele encontra mais um apenas dá um erro de "syntax"
	    -- Shift/Reduce 
	*/
	
OPERANDO    : TK_OP_REL
            
            | TK_OP_LOG
            
            | TK_OP_IGUALDADE
            ;

OPERACAO    : '(' OPERACAO ')'
            {
				$$.variavel = $2.variavel;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
            }
                
            | E OPERANDO E 
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
			
			
			/*
			// GERANDO SHIFT REDUCE. Precisa mesmo dessa regra? Consegui, aparentemente, continuar resolvendo tudo sem ela...
			
			| OPERACAO TK_OP_IGUALDADE OPERACAO
			{
			    $$.variavel = getID();			
				(*pilhaDeMapas.front())[$$.variavel] = {$$.variavel, "unsigned short int"};
				
				$$.tipo = "unsigned short int";
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.variavel + " = "+ $1.variavel + " " + $2.traducao + " " + $3.variavel + ";\n";
			    
			} */
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

struct info_funcao busca_funcao(string nome_funcao)
{
	string nome_args = nome_funcao;
	for(int i = 0; i < parametros.size(); i++)
		nome_args += parametros[i].tipo;
		
	if (tab_funcoes.find(nome_args) ==  tab_funcoes.end())         
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

vector<int> trata_tamanho(string tamanhos)
{
	for(int i = 0; i < tamanhos.length(); i++)
		if(tamanhos[i] == '[' || tamanhos[i] == ']')
			tamanhos[i] = ' ';
			
	istringstream iss(tamanhos);
	vector<int> valores;
	copy(istream_iterator<int>(iss),
         istream_iterator<int>(),
         back_inserter<vector<int> >(valores));

	return valores;
}

vector<string> calcula_posicao_vetor(string vetor_declarado, string tamanho)
{
	vector<int> tamanhos_chamada = trata_tamanho(tamanho);
	vector<int> tamanhos_declaracao = busca_no_mapa(vetor_declarado).tamanho_vet;
	vector<string> retorno;
	string traducao = "";
	
	string temp_aux = getID();
	(*pilhaDeMapas.front())[temp_aux] = {temp_aux, "int"};
	
	string temp_pos = getID();
	(*pilhaDeMapas.front())[temp_pos] = {temp_pos, "int"};
	
	string temp_aux2 = getID();
	(*pilhaDeMapas.front())[temp_aux2] = {temp_aux2, "int"};
	
	traducao += "\t" + temp_pos + " = 0;\n";
	
	int aux, pos = 0;
	
	for(int i = 0; i < tamanhos_declaracao.size(); i++)
	{
		aux = tamanhos_chamada[i];
		traducao += "\t" + temp_aux + " = " + to_string(tamanhos_chamada[i]) + ";\n";
		
		for(int j = (tamanhos_declaracao.size() - 1); j > i; j--)
		{
			aux *= tamanhos_declaracao[j];
			traducao += "\t" + temp_aux2 + " = " + to_string(tamanhos_declaracao[j]) + ";\n"; 
			traducao += "\t" + temp_aux + " = " + temp_aux + " * " + temp_aux2 + ";\n";
		}
		
		pos += aux;
		traducao += "\t" + temp_pos + " = " + temp_pos + " + " + temp_aux + ";\n";
	}
	
	retorno.push_back(temp_pos);
	retorno.push_back(traducao);
	
	return retorno;
}

/*

http://www.quut.com/c/ANSI-C-grammar-y.html

*/
