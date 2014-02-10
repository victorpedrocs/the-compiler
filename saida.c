/*Compilador C'*/
#include<stdio.h>
#include<string.h>
int main(void)
{
	int $temp7;
	int $temp8;
	int $temp3;
	int $temp4;
	int $temp6;
	int $temp5;
	float $temp0;
	unsigned short int $temp10;
	int $temp2;
	unsigned short int $temp9;
	int $temp1;
	//-------------
	$temp0 = 2.6;
	$temp2 = (int)$temp0;
	$temp1 = $temp2;

	label0:
	$temp3 = 1;
	$temp9 = $temp3 == $temp1;
	if($temp9) goto label2;
	$temp6 = 2;
	$temp10 = $temp6 == $temp1;
	if($temp10) goto label3;

	label2:
	$temp4 = 4;
	$temp5 = $temp4;

	label3:
	$temp7 = 10;
	$temp8 = $temp7;
	goto label1;

	label1:
	return 0;
}
