all:
	clear
	flex leitor_variavel.l
	gcc -o leitor lex.yy.c -lfl
	./leitor < primeiro_programa.c
