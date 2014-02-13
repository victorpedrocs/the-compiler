#include <iostream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <map>  
#include <utility>

using namespace std;

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
    map<string, struct variavel> tabela_variaveis;
    struct variavel var1 = {"cr", "temp0", "int"};
    
    tabela_variaveis.insert(pair<string, struct variavel>("cr", {"cr", "temp0", "int"}));

    cout << tabela_variaveis.find("cr")->second.tipo << endl;
    
    return 0;
}



