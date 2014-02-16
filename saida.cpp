/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

void $temp1()
{
	char $temp0[2];
	strcpy($temp0, "oi");
	cout << $temp0 << endl;
}

int $temp5(int $temp2, int $temp3)
{
	int $temp4;
	$temp4 = $temp2 + $temp3;
	return $temp4;
}

float $temp10(float $temp6, float $temp7)
{
	char $temp8[9];
	float $temp9;
	strcpy($temp8, "sou float");
	cout << $temp8 << endl;
	$temp9 = $temp6 + $temp7;
	return $temp9;
}

int main()
{
	int $temp11;
	int $temp12;
	int $temp13;
	float $temp14;
	float $temp15;
	float $temp16;
	int $temp18;
	float $temp17;
	$temp11 = 1;
	$temp12 = 4;
	$temp13 = $temp5($temp11, $temp12);
	cout << $temp13 << endl;
	$temp1();
	$temp14 = 4.4;
	$temp15 = 5.2;
	$temp16 = $temp10($temp14, $temp15);
	$temp17 = $temp16;
	cout << $temp17 << endl;
	$temp18 = 0;
	return $temp18;
}
