/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main(void)
{
	char $temp4[12];
	char $temp7[17];
	int $temp0;
	unsigned short int $temp10;
	int $temp11;
	int $temp2;
	unsigned short int $temp3;
	int $temp5;
	unsigned short int $temp6;
	char $temp8[15];
	unsigned short int $temp9;
	int $temp1;
	//-------------
	$temp0 = 32;
	$temp1 = $temp0;
	$temp2 = 2;
	$temp3 = $temp1 < $temp2;
	$temp10 = !($temp3);
	if($temp10) goto label2;
	strcpy($temp4, "Entrei no if");
	cout << $temp4 << endl;
	goto label3;

	label2:
	$temp5 = 5;
	$temp6 = $temp1 < $temp5;
	$temp9 = !($temp6);
	if($temp9) goto label0;
	strcpy($temp7, "Entrei no else if");
	cout << $temp7 << endl;
	goto label1;

	label0:
	strcpy($temp8, "Entrei no else!");
	cout << $temp8 << endl;

	label1:

	label3:
	$temp11 = 0;
	return $temp11;

}
