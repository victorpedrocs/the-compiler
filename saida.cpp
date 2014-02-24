/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int $temp0(int , int );


int main()
{
	char $temp1[3];
	char $temp3[3];
	char $temp4[6];
	int $temp5;
	int $temp6;
	int $temp7;
	int $temp8;
	char $temp2[3];
	strcpy($temp1, "oi");
	strcpy($temp2, $temp1);
	strcpy($temp3, "\n");
	strcpy($temp4, $temp2);
	strcat($temp4, $temp3);
	cout << $temp4;
	$temp5 = 1;
	$temp6 = 2;
	$temp7 = $temp0($temp5, $temp6);
	cout << $temp7;
	$temp8 = 0;
	return $temp8;
}

int $temp0(int $temp10, int $temp11)
{
	int $temp12;
	$temp12 = $temp10 + $temp11;
	return $temp12;
}
