/*Compilador C'*/
#include <iostream>
#include <string.h>
#include<string>
#include <stdio.h>
using namespace std;

int main()
{
	float $temp0;
	char $temp2[4];
	char $temp4[100];
	char $temp5[100];
	int $temp7;
	float $temp1;
	char $temp6[100];
	$temp0 = 10.493;
	$temp1 = $temp0;
	strcpy($temp2, "ola");
	sprintf($temp5, "%g",$temp1);
	strcpy($temp4, $temp5);
	strcat($temp4, $temp2);
	strcpy($temp6, $temp4);
	cout << $temp6;
	$temp7 = 0;
	return $temp7;
}
