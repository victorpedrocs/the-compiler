#include <iostream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <map>  
#include <utility>
#include <list>

using namespace std;
typedef map<string, struct variavel> mapa;
typedef map<string, struct variavel>::iterator mapa_it;
struct variavel buscaNoMapa(string var);
void getDeclaracoes(mapa* mapa_variaveis);
string declaracoes;

struct variavel
{
    string nome, nome_temp, tipo;
    int tamanho;
};

list<mapa*> pilhaDeMapas;

string getID()
{
	static int i = 0;

	stringstream ss;
	ss << "temp" << i++;
	
	return ss.str();
}

int main()
{
	mapa* mapa_variaveis = new mapa();
	mapa* mapa_variaveis2 = new mapa();
	(*mapa_variaveis)["a"] = {getID(), "ola", "int", 3};
	(*mapa_variaveis2)["b"] = {getID(), "sola", "string", 6};
	(*mapa_variaveis2)["c"] = {getID(), "ola2", "idsant", 8};
	pilhaDeMapas.push_front(mapa_variaveis);
	pilhaDeMapas.push_front(mapa_variaveis2);
	getDeclaracoes(pilhaDeMapas.front());
	pilhaDeMapas.pop_front();
	getDeclaracoes(pilhaDeMapas.front());
	cout << "e?\n\n" << declaracoes << endl;
	
}

struct variavel buscaNoMapa(string var)
{
	list<mapa*>::iterator iterator;
	mapa_it res;
	
	for(iterator = pilhaDeMapas.begin(); iterator != pilhaDeMapas.end(); iterator++)	
		if((res = (*iterator)->find(var)) != (*iterator)->end())
			return res->second;
	
	cout << "Variável \"" << var << "\" não declarada" << endl;
	exit(0);
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


