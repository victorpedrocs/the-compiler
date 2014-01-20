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
	int $a = 2;
	cout << $a << endl;
	
    
    return 0;
}



