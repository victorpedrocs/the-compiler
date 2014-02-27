int main()
{
	int vet[2][2];

	for(int i = 0; i < 2; i++)
	{
		for(int j = 0; j < 2; j++)
		{
			vet[i][j] = 0;
		}
	}
	
	for(int i = 0; i < 2; i++)
	{
		for(int j = 0; j < 2; j++)
		{
			print(vet[i][j]);
			print(" ");
		}
		print("\n");
	}	
	return 0;
}
