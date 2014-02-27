/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

void $temp1()
{
	char $temp0[14];
	strcpy($temp0, "vamos somar\n");
	cout << $temp0;
}

void $temp3()
{
	char $temp2[5];
	strcpy($temp2, "oi\n");
	cout << $temp2;
}

int main()
{
	char $temp12[10];
	int $temp10;
	int $temp11;
	char $temp13[17];
	int $temp9;
	unsigned short int $temp14;
	unsigned short int $temp15;
	unsigned short int $temp16;
	unsigned short int $temp17;
	int $temp18;
	int $temp4;
	char $temp6[21];
	int $temp7;
	unsigned short int $temp8;
	int $temp5;
	$temp4 = 1;
	$temp5 = $temp4;
	strcpy($temp6, "Entre com a opcao:\n");
	cout << $temp6;

	label0:
	$temp7 = 0;
	$temp8 = $temp5 != $temp7;
	$temp17 = !($temp8);
	if($temp17) goto label1;
	cin >> $temp5;

	label2:
	$temp9 = 1;
	$temp14 = $temp9 == $temp5;
	if($temp14) goto label4;
	$temp10 = 2;
	$temp15 = $temp10 == $temp5;
	if($temp15) goto label5;
	$temp11 = 0;
	$temp16 = $temp11 == $temp5;
	if($temp16) goto label6;
	goto label7;

	label4:
	$temp1();
	goto label3;

	label5:
	$temp3();
	goto label3;

	label6:
	strcpy($temp12, "saindo...");
	cout << $temp12;
	goto label3;

	label7:
	strcpy($temp13, "opcao invalida\n");
	cout << $temp13;

	label3:
	goto label0;

	label1:
	$temp18 = 0;
	return $temp18;
}
