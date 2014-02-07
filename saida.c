/*Compilador C'*/
#include<stdio.h>
#include<string.h>
int main(void)
{
	int $temp6;
	int $temp7;
	int $temp2;
	int $temp3;
	int $temp5;
	int $temp4;
	int $temp0;
	unsigned short int $temp8;
	unsigned short int $temp9;
	int $temp1;
	//-------------
	$temp0 = 2;
	$temp1 = $temp0;
	$temp2 = 1;
	$temp8 = $temp2 == $temp1;
	if($temp8) goto label0;
	$temp5 = 2;
	$temp9 = $temp5 == $temp1;
	if($temp9) goto label1;

	label0:
	$temp3 = 4;
	$temp4 = $temp3;

	label1:
	$temp6 = 10;
	$temp7 = $temp6;
	return 0;
}
