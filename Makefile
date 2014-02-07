all: 	
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -o glf y.tab.c -lfl -std=c++0x

		./glf < exemplo.cl > saida.c
		gcc saida.c
		./a.out
