/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main()
{
	int $temp0;
	char $temp2[4];
	char $temp3[6];
	char $temp4[0];
	int $temp6;
	int $temp1;
	char $temp5[6];
	$temp0 = 10;
	$temp1 = $temp0;
	strcpy($temp2, "alo");
	strcpy($temp3, $temp2);
	strcat($temp3, "10");
	strcpy($temp5, $temp3);
	cout << $temp5;
	$temp6 = 0;
	return $temp6;
}
