%{

#define NUM 100
#define ID 	101
#define TIPO 102
#define FLOAT 103
#define BINARIO 104
#define B	304
#define X	399


%}

BIN_DIG [0-1]
ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]


NUM {DIGITO}+
ID {LETRA}({NUM}|{LETRA})*
FLOAT {NUM}+("."{NUM}+)
BIN {BIN_DIG}+

CHAR \'({LETRA}|{NUM})\'
DELIM {ESPACO}+

%%
["int"|"float"]					{return TIPO;}
{ID}							{return ID;}
{NUM}							{return NUM;}
{FLOAT}							{return FLOAT;}
{BINARIO}						{return BINARIO};
<<EOF>>							{ return X; }

%%

int main(int argc, char *argv[])
{
	FILE *f_in;
	int tipoToken;
	int totalDig = 0,
		totalFLOAT = 0,
		totalTIPO = 0,
		totalBINARIO = 0,
		totalID = 0;

	if(argc == 2)
	{
		if(f_in == fopen(argv[1], "r"))
		{
			yyin = f_in;
		}
		else
		{
			perror(argv[0]);
		}
	}
	else
	{
		yyin = stdin;
	}

	while((tipoToken = yylex()) != X)
	{
		switch (tipoToken)
		{
			case NUM:
				++totalDig;
				break;
			case ID:
				++totalID;
				break;
			case TIPO:
				++totalTIPO;
				break;
			case FLOAT:
				++totalFLOAT;
				break;
			case BINARIO:
				++totalBINARIO;
				break;
		}
	}

	printf("Arquivo tem:\n");
	printf("\t %d valores decimais\n", totalDig);
	printf("\t %d valores reais\n", totalFLOAT);
	printf("\t %d identificadores\n", totalID);
	printf("\t %d tipos\n", totalTIPO);
	return 0;

}
