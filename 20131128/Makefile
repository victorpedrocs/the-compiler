all: 	
		clear
		flex calculadora.l
		bison -d calculadora.y
		g++ -o calculadora lex.yy.c calculadora.tab.c -lfl
		./calculadora
		
