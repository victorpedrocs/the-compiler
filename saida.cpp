/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main()
{
	char $temp0[2];
	int $temp2;
	char $temp1[2];
	strcpy($temp0, "oi");
	strcpy($temp1, $temp0);
	cout << $temp1<< endl;
	$temp2 = 0;
	return $temp2;
}
