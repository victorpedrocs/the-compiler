/*Compilador C'*/
#include <iostream>
#include <string.h>
#include<string>
#include <stdio.h>
using namespace std;	int _$temp0;
	int _$temp1;
	int _$temp3[9];
	char _$temp2[0];


int _$temp4(int , int );


float _$temp7(float _$temp5, float _$temp6);


void _$temp8();


void _$temp9();


int main()
{
	char _$temp14[31];
	char _$temp16[30];
	char _$temp18[13];
	int _$temp19;
	char _$temp21[100];
	char _$temp22[100];
	int _$temp15;
	int _$temp17;
	char _$temp24[31];
	char _$temp26[30];
	char _$temp28[13];
	float _$temp29;
	char _$temp31[100];
	char _$temp32[100];
	float _$temp27;
	float _$temp25;
	char _$temp36[14];
	int _$temp13;
	int _$temp23;
	int _$temp33;
	int _$temp34;
	int _$temp35;
	char _$temp37[19];
	char _$temp12[103];
	unsigned short int _$temp38;
	unsigned short int _$temp39;
	unsigned short int _$temp40;
	unsigned short int _$temp41;
	unsigned short int _$temp42;
	int _$temp10;
	unsigned short int _$temp11;
	unsigned short int _$temp43;
	int _$temp44;
	_$temp0 = 3;
	_$temp1 = _$temp0;

	label0:
	_$temp10 = 5;
	_$temp11 = _$temp1 != _$temp10;
	_$temp43 = !(_$temp11);
	if(_$temp43) goto label1;
	strcpy(_$temp12, "\n\nEntre com a opcao:\n1. soma inteiros \n2. soma float \n3. diz oi \n4. imprime matriz \n5. sair\n\n");
	cout << _$temp12;
	cin >> _$temp1;

	label2:
	_$temp13 = 1;
	_$temp38 = _$temp13 == _$temp1;
	if(_$temp38) goto label4;
	_$temp23 = 2;
	_$temp39 = _$temp23 == _$temp1;
	if(_$temp39) goto label5;
	_$temp33 = 3;
	_$temp40 = _$temp33 == _$temp1;
	if(_$temp40) goto label6;
	_$temp34 = 4;
	_$temp41 = _$temp34 == _$temp1;
	if(_$temp41) goto label7;
	_$temp35 = 5;
	_$temp42 = _$temp35 == _$temp1;
	if(_$temp42) goto label8;
	goto label9;

	label4:
	strcpy(_$temp14, " entre com o primeiro numero: ");
	cout << _$temp14;
	cin >> _$temp15;
	strcpy(_$temp16, " entre com o segundo numero: ");
	cout << _$temp16;
	cin >> _$temp17;
	strcpy(_$temp18, " resultado: ");
	_$temp19 = _$temp4(_$temp15, _$temp17);
	sprintf(_$temp22, "%d",_$temp19);
	strcpy(_$temp21, _$temp18);
	strcat(_$temp21, _$temp22);
	cout << _$temp21;
	goto label3;

	label5:
	strcpy(_$temp24, " entre com o primeiro numero: ");
	cout << _$temp24;
	cin >> _$temp25;
	strcpy(_$temp26, " entre com o segundo numero: ");
	cout << _$temp26;
	cin >> _$temp27;
	strcpy(_$temp28, " resultado: ");
	_$temp29 = _$temp7(_$temp25, _$temp27);
	sprintf(_$temp32, "%g",_$temp29);
	strcpy(_$temp31, _$temp28);
	strcat(_$temp31, _$temp32);
	cout << _$temp31;
	goto label3;

	label6:
	_$temp8();
	goto label3;

	label7:
	_$temp9();
	goto label3;

	label8:
	strcpy(_$temp36, "saindo...\n\n");
	cout << _$temp36;
	goto label3;

	label9:
	strcpy(_$temp37, "opcao invalida\n\n");
	cout << _$temp37;

	label3:
	goto label0;

	label1:
	_$temp44 = 0;
	return _$temp44;
}

int _$temp4(int _$temp46, int _$temp47)
{
	char _$temp48[25];
	int _$temp50;
	_$temp0 = 3;
	_$temp1 = _$temp0;
	strcpy(_$temp48, "estou somando inteiros\n");
	cout << _$temp48;
_$temp50 = _$temp46+_$temp47;
	return _$temp50;
}

float _$temp7(float _$temp51, float _$temp52)
{
	char _$temp53[23];
	float _$temp55;
	_$temp0 = 3;
	_$temp1 = _$temp0;
	strcpy(_$temp53, "estou somando floats\n");
	cout << _$temp53;
_$temp55 = _$temp51+_$temp52;
	return _$temp55;
}

void _$temp8()
{
	char _$temp57[11];
	char _$temp58[4];
	char _$temp60[100];
	char _$temp61[5];
	char _$temp63[100];
	char _$temp56[1000];
	_$temp0 = 3;
	_$temp1 = _$temp0;
	strcpy(_$temp57, "seu nome: ");
	cout << _$temp57;
	cin >> _$temp56;
	strcpy(_$temp58, "Oi ");
	strcpy(_$temp60, _$temp58);
	strcat(_$temp60, _$temp56);
	strcpy(_$temp61, "\n\n");
	strcpy(_$temp63, _$temp60);
	strcat(_$temp63, _$temp61);
	cout << _$temp63;
}

void _$temp9()
{
	char _$temp75[11];
	char _$temp77[100];
	char _$temp78[100];
	char _$temp79[3];
	char _$temp81[100];
	char _$temp83[100];
	char _$temp84[100];
	char _$temp85[4];
	char _$temp87[100];
	int _$temp88;
	int _$temp89;
	int _$temp90;
	int _$temp70;
	unsigned short int _$temp72;
	int _$temp73;
	int _$temp74;
	int _$temp91;
	int _$temp71;
	int _$temp65;
	unsigned short int _$temp67;
	int _$temp68;
	int _$temp69;
	int _$temp92;
	int _$temp66;
	int _$temp103;
	int _$temp104;
	int _$temp105;
	char _$temp106[2];
	char _$temp108[100];
	char _$temp109[100];
	unsigned short int _$temp100;
	int _$temp101;
	int _$temp102;
	int _$temp110;
	int _$temp98;
	int _$temp99;
	char _$temp111[3];
	int _$temp112;
	int _$temp93;
	unsigned short int _$temp95;
	int _$temp96;
	int _$temp97;
	int _$temp94;
	char _$temp113[6];
	int _$temp64;
	_$temp0 = 3;
	_$temp1 = _$temp0;
	_$temp65 = 0;
	_$temp66 = _$temp65;

	label15:
	_$temp67 = _$temp66 < _$temp1;
	_$temp92 = !(_$temp67);
	if(_$temp92) goto label11;
	_$temp70 = 0;
	_$temp71 = _$temp70;

	label14:
	_$temp72 = _$temp71 < _$temp1;
	_$temp91 = !(_$temp72);
	if(_$temp91) goto label13;
	strcpy(_$temp75, " posicao [");
	sprintf(_$temp78, "%d",_$temp66);
	strcpy(_$temp77, _$temp75);
	strcat(_$temp77, _$temp78);
	strcpy(_$temp79, "][");
	strcpy(_$temp81, _$temp77);
	strcat(_$temp81, _$temp79);
	sprintf(_$temp84, "%d",_$temp71);
	strcpy(_$temp83, _$temp81);
	strcat(_$temp83, _$temp84);
	strcpy(_$temp85, "]: ");
	strcpy(_$temp87, _$temp83);
	strcat(_$temp87, _$temp85);
	cout << _$temp87;
	cin >> _$temp64;
	_$temp89 = 0;//83
	_$temp88 = _$temp66;//1190
	_$temp90 = 3;//95
	_$temp88 = _$temp88 * _$temp90;//96
	_$temp89 = _$temp89 + _$temp88;//1200
	_$temp88 = _$temp71;//1190
	_$temp89 = _$temp89 + _$temp88;//1200
	_$temp3[_$temp89] = _$temp64;

	label12:
	_$temp73 = 1;
	_$temp74 = _$temp71 + _$temp73;
	_$temp71 = _$temp74;
	goto label14;

	label13:

	label10:
	_$temp68 = 1;
	_$temp69 = _$temp66 + _$temp68;
	_$temp66 = _$temp69;
	goto label15;

	label11:
	_$temp93 = 0;
	_$temp94 = _$temp93;

	label21:
	_$temp95 = _$temp94 < _$temp1;
	_$temp112 = !(_$temp95);
	if(_$temp112) goto label17;
	_$temp98 = 0;
	_$temp99 = _$temp98;

	label20:
	_$temp100 = _$temp99 < _$temp1;
	_$temp110 = !(_$temp100);
	if(_$temp110) goto label19;
	_$temp104 = 0;//83
	_$temp103 = _$temp94;//1190
	_$temp105 = 3;//95
	_$temp103 = _$temp103 * _$temp105;//96
	_$temp104 = _$temp104 + _$temp103;//1200
	_$temp103 = _$temp99;//1190
	_$temp104 = _$temp104 + _$temp103;//1200
	strcpy(_$temp106, " ");
	sprintf(_$temp109, "%d",_$temp3[_$temp104]);
	strcpy(_$temp108, _$temp109);
	strcat(_$temp108, _$temp106);
	cout << _$temp108;

	label18:
	_$temp101 = 1;
	_$temp102 = _$temp99 + _$temp101;
	_$temp99 = _$temp102;
	goto label20;

	label19:
	strcpy(_$temp111, "\n");
	cout << _$temp111;

	label16:
	_$temp96 = 1;
	_$temp97 = _$temp94 + _$temp96;
	_$temp94 = _$temp97;
	goto label21;

	label17:
	strcpy(_$temp113, "-----");
	cout << _$temp113;
}
