/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main()
{
	int $temp1;
	int $temp2;
	int $temp3;
	int $temp4;
	int $temp5;
	int $temp6;
	int $temp7;
	int $temp8;
	int $temp0[4];
	$temp1 = 3;
	$temp3 = 0;
	$temp2 = 1;
	$temp4 = 2;
	$temp2 = $temp2 * $temp4;
	$temp3 = $temp3 + $temp2;
	$temp2 = 1;
	$temp3 = $temp3 + $temp2;
	$temp0[$temp3] = $temp1;
	$temp6 = 0;
	$temp5 = 1;
	$temp7 = 2;
	$temp5 = $temp5 * $temp7;
	$temp6 = $temp6 + $temp5;
	$temp5 = 1;
	$temp6 = $temp6 + $temp5;
	cout << $temp0[$temp6] << endl;
	$temp8 = 0;
	return $temp8;
}
