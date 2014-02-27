/*Compilador C'*/
#include <iostream>
#include <string.h>

using namespace std;

int main()
{
	int $temp13;
	int $temp14;
	int $temp15;
	int $temp16;
	unsigned short int $temp10;
	int $temp11;
	int $temp12;
	int $temp17;
	int $temp7;
	int $temp9;
	int $temp8;
	int $temp1;
	int $temp18;
	int $temp3;
	unsigned short int $temp4;
	int $temp5;
	int $temp6;
	int $temp2;
	int $temp31;
	int $temp32;
	int $temp33;
	char $temp34[2];
	int $temp25;
	int $temp27;
	unsigned short int $temp28;
	int $temp29;
	int $temp30;
	int $temp35;
	int $temp26;
	char $temp36[3];
	int $temp19;
	int $temp21;
	unsigned short int $temp22;
	int $temp23;
	int $temp24;
	int $temp37;
	int $temp20;
	int $temp38;
	int $temp0[4];
	$temp1 = 0;
	$temp2 = $temp1;

	label5:
	$temp3 = 2;
	$temp4 = $temp2 < $temp3;
	$temp18 = !($temp4);
	if($temp18) goto label1;
	$temp7 = 0;
	$temp8 = $temp7;

	label4:
	$temp9 = 2;
	$temp10 = $temp8 < $temp9;
	$temp17 = !($temp10);
	if($temp17) goto label3;
	$temp13 = 0;
	$temp15 = 0;//83
	$temp14 = $temp2;//1190
	$temp16 = 2;//95
	$temp14 = $temp14 * $temp16;//96
	$temp15 = $temp15 + $temp14;//1200
	$temp14 = $temp8;//1190
	$temp15 = $temp15 + $temp14;//1200
	$temp0[$temp15] = $temp13;

	label2:
	$temp11 = 1;
	$temp12 = $temp8 + $temp11;
	$temp8 = $temp12;
	goto label4;

	label3:

	label0:
	$temp5 = 1;
	$temp6 = $temp2 + $temp5;
	$temp2 = $temp6;
	goto label5;

	label1:
	$temp19 = 0;
	$temp20 = $temp19;

	label11:
	$temp21 = 2;
	$temp22 = $temp20 < $temp21;
	$temp37 = !($temp22);
	if($temp37) goto label7;
	$temp25 = 0;
	$temp26 = $temp25;

	label10:
	$temp27 = 2;
	$temp28 = $temp26 < $temp27;
	$temp35 = !($temp28);
	if($temp35) goto label9;
	$temp32 = 0;//83
	$temp31 = $temp20;//1190
	$temp33 = 2;//95
	$temp31 = $temp31 * $temp33;//96
	$temp32 = $temp32 + $temp31;//1200
	$temp31 = $temp26;//1190
	$temp32 = $temp32 + $temp31;//1200
	cout << $temp0[$temp32];
	strcpy($temp34, " ");
	cout << $temp34;

	label8:
	$temp29 = 1;
	$temp30 = $temp26 + $temp29;
	$temp26 = $temp30;
	goto label10;

	label9:
	strcpy($temp36, "\n");
	cout << $temp36;

	label6:
	$temp23 = 1;
	$temp24 = $temp20 + $temp23;
	$temp20 = $temp24;
	goto label11;

	label7:
	$temp38 = 0;
	return $temp38;
}
