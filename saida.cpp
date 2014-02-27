/*Compilador C'*/
#include <iostream>
#include <string.h>
#include<string>
#include <stdio.h>
using namespace std;

int main()
{
	char $temp0;
	char $temp3[100];
	char $temp4[100];
	char $temp5[100];
	int $temp7;
	char $temp1;
	char $temp6[0];
	$temp0 = 'K';
	$temp1 = $temp0;
	sprintf($temp4, "%c",$temp1);
	sprintf($temp5, "%c",$temp1);
	strcpy($temp3, $temp4);
	strcat($temp3, $temp5);
	strcpy($temp6, $temp3);
	cout << $temp6;
	$temp7 = 0;
	return $temp7;
}
