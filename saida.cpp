/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main()
{
	int $temp0;
	int $temp11;
	char $temp2[4];
	char $temp3[6];
	char $temp4[0];
	int $temp6;
	char $temp7[3];
	char $temp8[5];
	char $temp9[0];
	int $temp1;
	char $temp5[6];
	char $temp10[5];
	$temp0 = 10;
	$temp1 = $temp0;
	strcpy($temp2, "alo");
	strcpy($temp3, $temp2);
	strcat($temp3, "10");
	strcpy($temp5, $temp3);
	$temp6 = 13;
	$temp1 = $temp6;
	cout << $temp5;
	strcpy($temp7, "eu");
	strcpy($temp8, $temp7);
	strcat($temp8, "10");
	strcpy($temp10, $temp8);
	cout << $temp10;
	$temp11 = 0;
	return $temp11;
}
