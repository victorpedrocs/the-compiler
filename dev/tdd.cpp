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

struct variavel
{
    string nome, nome_temp, tipo;
};


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
	//(*mapa_variaveis)["scheisse"] = {getID()};
	//cout << (*mapa_variaveis)["scheisse"].nome << endl;
	list<mapa*> pilhaDeMapas;

	pilhaDeMapas.push_front(mapa_variaveis);		
	
}



