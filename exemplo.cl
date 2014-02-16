void diz_oi()
{
	print("oi");
}

int soma(int a, int b)
{
	return a + b;
}

float soma(float a, float b)
{
	print("sou float");
	return a + b;
}

int main()
{
	print(soma(1, 4));
	diz_oi();
	float i = soma(4.4, 5.2);
	print(i);
	return 0;
}

