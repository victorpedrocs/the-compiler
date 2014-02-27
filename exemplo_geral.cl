int a = 3;
string str;
int matriz[3][3];

int soma(int, int);
float soma(float i, float j);
void diz_oi();
void matriz();


int main()
{
	while(a != 5)
	{
		print("\n\nEntre com a opcao:\n1. soma inteiros \n2. soma float \n3. diz oi \n4. imprime matriz \n5. sair\n\n");
		scan(a);
		switch(a)
		{
			case 1:
			{
				print(" entre com o primeiro numero: ");
				int x;
				scan(x);
				print(" entre com o segundo numero: ");
				int y;
				scan(y);
				print(" resultado: " + soma(x, y));
				break;
			}
			case 2:
			{
				print(" entre com o primeiro numero: ");
				float z;
				scan(z);
				print(" entre com o segundo numero: ");
				float t;
				scan(t);
				print(" resultado: " + soma(z, t));
				break;
			}
			case 3:
			{
				diz_oi();
				break;
			}
			
			case 4:
			{
				matriz();
				break;
			}
			case 5:
			{
				print("saindo...\n\n");
				break;
			}
			default:
				print("opcao invalida\n\n");
		}
	}
	
	return 0;
	
}

int soma(int x, int y)
{
	print("estou somando inteiros\n");
	return x + y;
}

float soma(float i, float j)
{
	print("estou somando floats\n");
	return i+j;
}

void diz_oi()
{
	string nome;
	print("seu nome: ");
	scan(nome);
	print("Oi " + nome + "\n\n");
}

void matriz()
{
	int temp;
	for (int i = 0; i < a; i++)
		for(int j = 0; j < a; j++)
		{
			print(" posicao [" + i + "][" +  j + "]: ");
			scan(temp);
			matriz[i][j] = temp;
		}
		
		
	//impressao
	for (int i = 0; i < a; i++)
	{
		for(int j = 0; j < a; j++)
		{
			print(matriz[i][j] + " ");
		}
		
		print("\n");
	}
	
	print("-----");
}
