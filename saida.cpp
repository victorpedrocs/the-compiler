/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int $temp3(int $temp0, int $temp1)
{
	int $temp2;
	$temp2 = $temp0 + $temp1;
	return $temp2;
}

int main()
{
	int $temp4;
	int $temp5;
	int $temp6;
	int $temp8;
	int $temp7;
	$temp4 = 1;
	$temp5 = 2;
	$temp6 = $temp3($temp4, $temp5);
	$temp7 = $temp6;
	cout << $temp7 << endl;
	$temp8 = 0;
	return $temp8;
}
