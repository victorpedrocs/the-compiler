#include <iostream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>

using namespace std;


string getID()
{
	static int i = 0;

	stringstream ss;
	ss << "temp" << i++;
	
	return ss.str();
}

int main()
{
	int i;
	string z;
	for(i=0; i<10;i++)	
		cout << getID() << endl;


	return 0;
}
