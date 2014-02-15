/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main(void)
{
	unsigned short int $temp2;
	unsigned short int $temp3;
	int $temp4;
	int $temp5;
	int $temp6;
	int $temp0;
	int $temp1;
	//-------------
	$temp2 = $temp0 < $temp1;
	$temp3 = !($temp2);
	if($temp3) goto label0;

	label0:
	$temp4 = 1;
	$temp5 = !($temp4);
	if($temp5) goto label2;

	label2:
	$temp6 = 0;
	return $temp6;

}
