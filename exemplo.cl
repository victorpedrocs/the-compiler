void soma()
{
	print("vamos somar\n");
}

void dizOI()
{
	print("oi\n");
}

int main()
{
	int a = 1;
	
	print("Entre com a opcao:\n");
	
	while(a != 0)
	{
		scan(a);
		switch(a)
		{
			case 1:
			{
				soma();
				break;
			}
			case 2:
			{
				dizOI();
				break;
			}
			case 0:
			{
				print("saindo...\n");
				break;
			}
			default:
				print("opcao invalida\n");
		}
	}
	return 0;
}
