/*Compilador C'*/
#include <iostream>
#include <string.h>
#include<string>
#include <stdio.h>
using namespace std;

int main()
{
	int $temp0;
	char $temp2[4];
	char $temp3[104];
	char $temp4[104];
	char $temp5[0];
	int $temp7;
	int $temp1;
	char $temp6[104];
	$temp0 = 10;
	$temp1 = $temp0;
	strcpy($temp2, "alo");
	sprintf($temp4, "%d",$temp1);
	strcpy($temp3, $temp2);
	strcat($temp3, $temp4);
	strcpy($temp6, $temp3);
	cout << $temp6;
	$temp7 = 0;
	return $temp7;
}
