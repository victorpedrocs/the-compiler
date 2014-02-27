int main(void)
{
	int d = 3;
	int size = 3;

	int matrix[3][3];

	// fill the diagonal of matrix with d
	for (int i = 0; i < size; i++)
		for(int j = 0; j < size; j++)
		{
			if (i == j)
				matrix[i][j] = d;
			else
				matrix[i][j] = 0;
		}

	// print matrix
	for (int i = 0; i < size; i++)
	{
		for(int j = 0; j < size; j++)
		{
			print(matrix[i][j] + " ");
		}
		print("\n");
	}

	return 0;
}
