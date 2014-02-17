/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main()
{
	char $temp0[3];
	int $temp2;
	char $temp1[3];
	strcpy($temp0, "oi");
	strcpy($temp1, $temp0);
	cout << $temp1;
	$temp2 = 0;
	return $temp2;
}
