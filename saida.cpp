/*Compilador C'*/
#include <iostream>
#include <string.h>
#include<string>
#include <stdio.h>
using namespace std;

int main()
{
	int $temp0;
	int $temp11;
	char $temp2[4];
<<<<<<< HEAD
	char $temp3[104];
	char $temp4[104];
	char $temp5[0];
	int $temp7;
	int $temp1;
	char $temp6[104];
=======
	char $temp3[6];
	char $temp4[0];
	int $temp6;
	char $temp7[3];
	char $temp8[5];
	char $temp9[0];
	int $temp1;
	char $temp5[6];
	char $temp10[5];
>>>>>>> 0a9aadc5c9eaf1976e47308a9c05ce4c1427a82c
	$temp0 = 10;
	$temp1 = $temp0;
	strcpy($temp2, "alo");
	sprintf($temp4, "%d",$temp1);
	strcpy($temp3, $temp2);
<<<<<<< HEAD
	strcat($temp3, $temp4);
	strcpy($temp6, $temp3);
	cout << $temp6;
	$temp7 = 0;
	return $temp7;
=======
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
>>>>>>> 0a9aadc5c9eaf1976e47308a9c05ce4c1427a82c
}
